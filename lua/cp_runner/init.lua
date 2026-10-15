local M = {}
local api = vim.api
local active
local inputs = {}
local options = {}

local function notify(message)
	vim.notify(message, vim.log.levels.ERROR, { title = "CP Test" })
end

local function detect_filetype(path)
	local extension = vim.fn.fnamemodify(path, ":e")
	return ({ cpp = "cpp", py = "python" })[extension]
end

local function output(session, text, title)
	if not api.nvim_buf_is_valid(session.output_buf) then return end
	vim.bo[session.output_buf].modifiable = true
	api.nvim_buf_set_lines(session.output_buf, 0, -1, false, vim.split(text, "\n", { plain = true }))
	vim.bo[session.output_buf].modifiable = false
	if api.nvim_win_is_valid(session.output_win) then
		api.nvim_win_set_config(session.output_win, { title = " " .. title .. " " })
	end
end

local function layout()
	local width = math.min(math.floor(vim.o.columns * 0.9), vim.o.columns - 4)
	local height = math.min(math.floor(vim.o.lines * 0.7), vim.o.lines - 6)
	if width < 36 or height < 4 then return end
	local left = math.floor((width - 4) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.max(0, math.floor((vim.o.lines - height - 4) / 2))
	return {
		{ relative = "editor", row = row, col = col, width = left, height = height, style = "minimal", border = "rounded" },
		{ relative = "editor", row = row, col = col + left + 2, width = width - left - 4, height = height, style = "minimal", border = "rounded" },
	}
end

function M.stop()
	if active and active.job then active.job.cancel() end
end

function M.close()
	local session = active
	if not session then return end
	active = nil -- Invalidate callbacks before closing windows or stopping a job.
	if session.job then session.job.cancel() end
	api.nvim_del_augroup_by_id(session.group)
	if api.nvim_buf_is_valid(session.input_buf) then
		inputs[session.path] = api.nvim_buf_get_lines(session.input_buf, 0, -1, false)
	end
	vim.cmd.stopinsert()
	for _, win in ipairs({ session.input_win, session.output_win }) do
		if api.nvim_win_is_valid(win) then api.nvim_win_close(win, true) end
	end
	for _, buf in ipairs({ session.input_buf, session.output_buf }) do
		if api.nvim_buf_is_valid(buf) then api.nvim_buf_delete(buf, { force = true }) end
	end
	if api.nvim_win_is_valid(session.source_win) then api.nvim_set_current_win(session.source_win) end
end

function M.run()
	local session = active
	if not session then return end
	if not api.nvim_buf_is_valid(session.source_buf) then
		output(session, "源文件 buffer 已关闭，请重新打开测试窗口。", "Error")
		return
	end
	-- Invalidate the previous callback before cancelling a repeated run.
	session.generation = session.generation + 1
	local generation = session.generation
	if session.job then session.job.cancel() end
	session.job = nil
	session.result = nil
	session.path = api.nvim_buf_get_name(session.source_buf)
	session.filetype = detect_filetype(session.path)
	if not session.filetype then
		output(session, "仅支持 .cpp 和 .py 文件，请检查源文件后缀。", "Error")
		return
	end
	local ok, err = pcall(api.nvim_buf_call, session.source_buf, function() vim.cmd("silent update") end)
	if not ok then
		output(session, "保存源文件失败：\n" .. tostring(err), "Error")
		return
	end
	session.path = api.nvim_buf_get_name(session.source_buf)
	local lines = api.nvim_buf_get_lines(session.input_buf, 0, -1, false)
	inputs[session.path] = lines
	local input = table.concat(lines, "\n")
	if input ~= "" then input = input .. "\n" end
	session.job = require("cp_runner.runner").start(session.path, session.filetype, input, options, function(result)
		if active ~= session or generation ~= session.generation then return end
		session.job = nil
		session.result = result
		local status = result.phase == "compile" and "Compile error" or "Exit " .. result.code
		if result.reason == "timeout" then status = "Time limit exceeded"
		elseif result.reason == "cancelled" then status = "Stopped"
		elseif result.reason == "output_limit" then status = "Output limit exceeded" end
		local text = result.stdout
		if text == "" then text = "(无标准输出)" end
		if result.stderr ~= "" then text = text .. "\n\n── stderr ──\n" .. result.stderr end
		output(session, text, string.format("%s | %.0f ms", status, result.elapsed_ms))
	end, function(phase)
		output(session, phase == "compile" and "正在编译…" or "正在运行…", "Output")
	end)
end

function M.open()
	if active then
		api.nvim_set_current_win(active.input_win)
		return active
	end
	local source_buf = api.nvim_get_current_buf()
	local path = api.nvim_buf_get_name(source_buf)
	if path == "" or vim.bo[source_buf].buftype ~= "" then
		notify("请先将代码保存为 .cpp 或 .py 文件。")
		return
	end
	local filetype = detect_filetype(path)
	if not filetype then
		notify("仅支持 .cpp 和 .py 文件，当前文件后缀不受支持。")
		return
	end
	local configs = layout()
	if not configs then
		notify("窗口太小，请扩大 Neovim 后重试。")
		return
	end
	local session = {
		source_buf = source_buf, source_win = api.nvim_get_current_win(),
		path = path, filetype = filetype, generation = 0,
		input_buf = api.nvim_create_buf(false, true), output_buf = api.nvim_create_buf(false, true),
	}
	active = session
	for _, buf in ipairs({ session.input_buf, session.output_buf }) do
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].swapfile = false
		vim.bo[buf].filetype = "cp_test"
		vim.bo[buf].undofile = false
	end
	api.nvim_buf_set_lines(session.input_buf, 0, -1, false, inputs[path] or { "" })
	configs[1].title = " Input (stdin) "
	configs[1].footer = " Ctrl+r: run | Tab: switch "
	configs[2].title = " Output (stdout) "
	configs[2].footer = " q: close | Ctrl+c: stop "
	session.input_win = api.nvim_open_win(session.input_buf, true, configs[1])
	session.output_win = api.nvim_open_win(session.output_buf, false, configs[2])
	for _, win in ipairs({ session.input_win, session.output_win }) do
		vim.wo[win].wrap = false
		vim.wo[win].cursorline = true
	end
	output(session, "在左侧输入测试用例，按 Ctrl+r 运行。", "Output (stdout)")
	local function switch()
		vim.cmd.stopinsert()
		local target = api.nvim_get_current_win() == session.input_win and session.output_win or session.input_win
		api.nvim_set_current_win(target)
	end
	for _, buf in ipairs({ session.input_buf, session.output_buf }) do
		local function map(modes, key, fn, desc)
			vim.keymap.set(modes, key, fn, { buffer = buf, silent = true, desc = desc })
		end
		map({ "n", "i" }, "<C-r>", M.run, "Run test case")
		map({ "n", "i" }, "<C-c>", M.stop, "Stop test")
		map({ "n", "i" }, "<Tab>", switch, "Switch input/output")
		map({ "n", "i" }, "<S-Tab>", switch, "Switch input/output")
		map("n", "q", M.close, "Close test window")
		map("n", "<Esc>", M.close, "Close test window")
	end
	session.group = api.nvim_create_augroup("CPTestSession", { clear = true })
	api.nvim_create_autocmd("WinClosed", {
		group = session.group,
		pattern = { tostring(session.input_win), tostring(session.output_win) },
		callback = function()
			vim.schedule(function() if active == session then M.close() end end)
		end,
	})
	api.nvim_create_autocmd("VimResized", {
		group = session.group,
		callback = function()
			local resized = layout()
			if not resized then M.close(); return end
			for i, win in ipairs({ session.input_win, session.output_win }) do
				if api.nvim_win_is_valid(win) then api.nvim_win_set_config(win, resized[i]) end
			end
		end,
	})
	vim.cmd.startinsert()
	return session
end

function M.setup(opts)
	options = opts or {}
	api.nvim_create_user_command("CPTest", M.open, { desc = "Test current C++ / Python program" })
	api.nvim_create_user_command("CPTestRun", M.run, { desc = "Run current test input" })
	api.nvim_create_user_command("CPTestStop", M.stop, { desc = "Stop current test" })
	vim.keymap.set("n", "<leader>ti", M.open, { desc = "[CP] Test input / output" })
	local group = api.nvim_create_augroup("CPTest", { clear = true })
	api.nvim_create_autocmd("VimLeavePre", { group = group, callback = M.close })
end

return M
