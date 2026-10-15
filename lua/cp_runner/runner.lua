local M = {}

M.defaults = {
	cpp = "g++",
	cpp_flags = { "-std=c++23", "-O2", "-Wall", "-Wextra" },
	timeout = 5000,
	compile_timeout = 30000,
	output_limit = 1024 * 1024,
}

-- on_done runs on Neovim's main loop. Commands use argv, never shell expansion.
function M.start(path, filetype, input, options, on_done, on_phase)
	local opts = vim.tbl_extend("force", M.defaults, options or {})
	local handle = {}
	local process, timer, reason
	local finished = false
	local process_groups = vim.fn.has("win32") == 0

	local function stop_timer()
		if timer then
			timer:stop()
			timer:close()
			timer = nil
		end
	end

	local function finish(result)
		if finished then return end
		finished = true
		stop_timer()
		if handle.temp_dir then vim.fn.delete(handle.temp_dir, "rf") end
		on_done(result)
	end

	local function kill(why)
		if finished or reason then return end
		reason = why
		if process then
			-- Detached Unix jobs lead a new process group. Kill the group so
			-- compiler/program children cannot keep stdout/stderr pipes alive.
			if process_groups then pcall(vim.uv.kill, -process.pid, 9) end
			pcall(process.kill, process, 9)
		end
	end
	handle.cancel = function() kill("cancelled") end

	local function spawn(argv, phase, stdin, timeout, next_step)
		if reason then
			finish({ code = -1, stdout = "", stderr = "", phase = phase, reason = reason, elapsed_ms = 0 })
			return
		end
		if on_phase then on_phase(phase) end
		local started = vim.uv.hrtime()
		local streams = { stdout = {}, stderr = {} }
		local size = 0
		local function collect(stream)
			return function(err, data)
				data = data or (err and tostring(err))
				if not data then return end
				local remaining = math.max(0, opts.output_limit - size)
				streams[stream][#streams[stream] + 1] = data:sub(1, remaining)
				size = size + math.min(#data, remaining)
				if #data > remaining then kill("output_limit") end
			end
		end
		local ok, result = pcall(vim.system, argv, {
			cwd = vim.fs.dirname(path),
			detach = process_groups,
			stdin = stdin,
			text = true,
			stdout = collect("stdout"),
			stderr = collect("stderr"),
		}, vim.schedule_wrap(function(exit)
			process = nil
			stop_timer()
			exit.stdout = table.concat(streams.stdout)
			exit.stderr = table.concat(streams.stderr)
			exit.phase = phase
			exit.reason = reason
			exit.elapsed_ms = (vim.uv.hrtime() - started) / 1e6
			if exit.code == 0 and not reason and next_step then
				next_step()
			else
				finish(exit)
			end
		end))
		if not ok then
			vim.schedule(function()
				finish({ code = -1, stdout = "", stderr = tostring(result), phase = phase, elapsed_ms = 0 })
			end)
			return
		end
		process = result
		timer = vim.uv.new_timer()
		timer:start(timeout, 0, function() kill("timeout") end)
	end

	if filetype == "cpp" then
		handle.temp_dir = vim.fn.tempname()
		vim.fn.mkdir(handle.temp_dir, "p")
		local executable = handle.temp_dir .. "/solution"
		local argv = { opts.cpp }
		vim.list_extend(argv, opts.cpp_flags)
		vim.list_extend(argv, { path, "-o", executable })
		spawn(argv, "compile", nil, opts.compile_timeout, function()
			spawn({ executable }, "run", input, opts.timeout)
		end)
	elseif filetype == "python" then
		local python = opts.python or require("core.python").get_python_path() or "python3"
		spawn({ python, "-u", path }, "run", input, opts.timeout)
	else
		vim.schedule(function()
			finish({ code = -1, stdout = "", stderr = "Only C++ and Python are supported", phase = "run", elapsed_ms = 0 })
		end)
	end
	return handle
end

return M
