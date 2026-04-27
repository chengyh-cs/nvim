return {
	-- NOTE: bufferline
	{
		"akinsho/bufferline.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(_, _, diagnostics_dict, _)
					local indicator = " "
					for level, number in pairs(diagnostics_dict) do
						local symbol
						if level == "error" then
							symbol = " "
						elseif level == "warning" then
							symbol = " "
						else
							symbol = " "
						end
						indicator = indicator .. number .. symbol
					end
					return indicator
				end,
			},
		},
		keys = {},
		lazy = false,
	},
	-- NOTE: nvim-treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"lua",
				"toml",
				"cpp",
				"c",
				"python",
				"vim",
				"vimdoc",
				"markdown",
				"markdown_inline",
			},

			-- 自动安装缺失的解析器
			auto_install = true,

			-- 启动时异步安装, 避免阻塞 Neovim
			sync_install = false,

			-- 核心：高亮模块的详细配置
			highlight = {
				enable = true, -- 启用基于 Treesitter 的高亮

				-- 这是解决 Doctest 高亮问题的关键步骤之一
				additional_vim_regex_highlighting = false,

				-- ✨ 核心修正：确保代码注入功能开启，这是doctest高亮的关键
				enable_injection = true,
			},
		},
	},
	-- NOTE: telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && "
					.. "cmake --build build --config Release && "
					.. "cmake --install build --prefix build",
			},
		},
		cmd = "Telescope",
		opts = {
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			telescope.load_extension("fzf")
		end,
	},
	-- NOTE: which-key --> 显示快捷键
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			---@type false | "classic" | "modern" | "helix"
			preset = "helix",
			win = {
				-- no_overlap = true,
				title = false,
				width = 0.5,
			},
			-- expand all nodes wighout a description
			expand = function(node)
				return not node.desc
			end,
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "[Which-key] Buffer Local Keymaps",
			},
		},
	},
	-- NOTE: yazi
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		dependencies = {
			-- check the installation instructions at
			-- https://github.com/folke/snacks.nvim
			"folke/snacks.nvim",
		},
		keys = {
			-- 👇 in this section, choose your own keymappings!
			{
				"<leader>yy",
				mode = { "n", "v" },
				"<cmd>Yazi<cr>",
				desc = "[yazi] Open yazi",
			},
			-- {
			-- 	"<c-up>",
			-- 	"<cmd>Yazi toggle<cr>",
			-- 	desc = "Resume the last yazi session",
			-- },
		},
		---@type YaziConfig | {}
		opts = {
			-- if you want to open yazi instead of netrw, see below for more info
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
		},
		-- 👇 if you use `open_for_directories=true`, this is recommended
		init = function()
			-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
			-- vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
	},
	-- NOTE: toggleterm --> 终端
	{
		"akinsho/toggleterm.nvim",
		version = "*", -- 或者指定一个版本，例如 "v2.9.0"
		config = function()
			require("toggleterm").setup({
				-- 窗口大小，可以是整数（行数）或浮点数（占屏幕的百分比）
				size = function(term)
					if term.direction == "horizontal" then
						return 14
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
					return 30 -- 默认浮动窗口高度
				end,

				-- 打开终端时的映射，<C-\> 是一个不错的选择，因为它在插入和正常模式下都可用
				-- 注意：这个映射会打开一个默认的终端。我们通常会为不同终端设置更具体的快捷键。
				-- 设置为 false 可以禁用这个默认映射。
				open_mapping = [[<c-\>]],

				-- 在插入模式下，<esc> 会发送到终端，而不是退出插入模式。
				-- 设置为 true 可以让你在终端的插入模式下按 <esc> 切换到正常模式。
				insert_mappings = true,

				-- 终端打开时立即进入插入模式
				start_in_insert = true,

				-- 是否在终端缓冲区保留光标位置
				persist_cursor = true,

				-- 是否在窗口关闭时保留终端任务，再次打开时恢复
				persist_mode = true,

				-- 按下 <esc> 键时是否关闭终端窗口
				close_on_exit = true,

				-- 默认 shell
				shell = vim.o.shell,

				-- 终端窗口的默认方向: 'float', 'vertical', 'horizontal'
				direction = "float",

				-- 浮动窗口的配置
				float_opts = {
					-- 边框样式，可以是 'single', 'double', 'rounded', 'solid', 'shadow'
					border = "rounded",
					winblend = 0,
					highlights = {
						border = "Normal",
						background = "Normal",
					},
				},
			})

			-- 定义自定义函数来简化快捷键映射
			function _G.set_terminal_keymaps()
				local opts = { noremap = true, silent = true }
				-- 普通浮动终端
				vim.api.nvim_set_keymap("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", opts)
				-- 垂直终端
				vim.api.nvim_set_keymap("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", opts)
				-- 水平终端
				vim.api.nvim_set_keymap("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", opts)

				-- 退出终端模式的快捷键，在终端窗口中，按 <esc><esc> 返回正常模式
				-- 这是 toggleterm 的默认行为，但在这里明确写出来以供参考
				-- vim.api.nvim_set_keymap('t', '<esc><esc>', '<c-\\><c-n>', opts)
			end

			-- 调用函数来设置快捷键
			_G.set_terminal_keymaps()

			-- 定义一些用于特定终端的快捷键
			-- 这是一个更好的实践，因为它将配置和快捷键分开管理
			local Terminal = require("toggleterm.terminal").Terminal

			-- Lazygit
			local lazygit = Terminal:new({
				cmd = "lazygit",
				dir = vim.fn.getcwd(),
				direction = "float",
				-- 进入终端时执行的函数
				on_open = function(term)
					vim.cmd("startinsert!")
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"n",
						"q",
						"<cmd>close<CR>",
						{ noremap = true, silent = true }
					)
				end,
				-- 关闭终端时执行的函数
				on_close = function(term)
					-- 可选：关闭时做一些清理工作
				end,
			})

			function _G.toggle_lazygit()
				lazygit:toggle()
			end

			vim.api.nvim_set_keymap(
				"n",
				"<leader>gg",
				"<cmd>lua _G.toggle_lazygit()<CR>",
				{ noremap = true, silent = true }
			)

			-- ===============================================================
			-- ✨ 新增：C++ 编译并运行
			-- ===============================================================
			-- function _G.compile_and_run_cpp()
			-- 	-- 1. 检查当前文件是否为 C++ 文件
			-- 	if vim.bo.filetype ~= "cpp" then
			-- 		vim.notify("Error: Not a C++ file.", vim.log.levels.ERROR)
			-- 		return
			-- 	end
			--
			-- 	-- 2. 保存当前文件，确保编译的是最新版本
			-- 	vim.cmd("write")
			--
			-- 	-- 3. 构建命令
			-- 	local file_path = vim.fn.expand("%")
			-- 	local executable_path = vim.fn.expand("%:r")
			-- 	local cmd =
			-- 		string.format("g++ -std=c++23 %s -o %s && %s", file_path, executable_path, executable_path)
			--
			-- 	-- 4. 【核心修正】在函数内部动态创建一个新的终端实例并立即执行
			-- 	local term = require("toggleterm.terminal").Terminal:new({
			-- 		cmd = cmd,
			-- 		direction = "float",
			-- 		close_on_exit = false,
			-- 		-- 进入终端时自动开始执行命令
			-- 		on_open = function(t)
			-- 			vim.cmd("startinsert!")
			-- 		end,
			-- 	})
			-- 	term:toggle()
			-- end
			--
			-- vim.api.nvim_set_keymap(
			-- 	"n",
			-- 	"<leader>tc", -- t -> terminal, c -> cpp
			-- 	"<cmd>lua _G.compile_and_run_cpp()<CR>",
			-- 	{ noremap = true, silent = true, desc = "Compile and run C++ file" }
			-- )

			-- local interactive_cpp_term = require("toggleterm.terminal").Terminal:new({
			-- 	id = "interactive_cpp_runner",
			-- 	direction = "float",
			-- 	close_on_exit = false,
			-- })
			--
			-- function _G.compile_and_run_cpp_interactive()
			-- 	if vim.bo.filetype ~= "cpp" then
			-- 		vim.notify("Error: Not a C++ file.", vim.log.levels.ERROR)
			-- 		return
			-- 	end
			-- 	vim.cmd("write")
			--
			-- 	local dir_path = vim.fn.shellescape(vim.fn.expand("%:p:h"))
			-- 	local source_file_abs_path = vim.fn.shellescape(vim.fn.expand("%:p"))
			-- 	local executable_name_relative = vim.fn.shellescape(vim.fn.expand("%:t:r"))
			--
			-- 	local cmd = string.format(
			-- 		"cd %s && g++ -std=c++23 %s -o %s && ./%s",
			-- 		dir_path,
			-- 		source_file_abs_path,
			-- 		executable_name_relative,
			-- 		executable_name_relative
			-- 	)
			--
			-- 	interactive_cpp_term.on_open = function(term)
			-- 		-- 1. 发送命令
			-- 		term:send(cmd, true)
			--
			-- 		-- term.window 是 toggleterm 提供的 API，用于获取终端的 Neovim 窗口 ID
			-- 		vim.api.nvim_set_current_win(term.window)
			--
			-- 		-- 3. 清理一次性钩子
			-- 		term.on_open = nil
			-- 	end
			--
			-- 	interactive_cpp_term:toggle()
			-- end
			--
			-- vim.api.nvim_set_keymap(
			-- 	"n",
			-- 	"<leader>tc",
			-- 	"<cmd>lua _G.compile_and_run_cpp_interactive()<CR>",
			-- 	{ noremap = true, silent = true, desc = "Compile and run C++ file and keep focus" }
			-- )
			-- ===============================================================
			-- ✨ 最终版：统一的交互式运行器 (支持 C++ 和 Python)
			-- ===============================================================

			-- 1. 定义一个统一的、持久的、可复用的交互式终端实例
			-- 我们将它重命名为更通用的 'interactive_runner_term'
			local interactive_runner_term = require("toggleterm.terminal").Terminal:new({
				id = "interactive_runner",
				direction = "float",
				close_on_exit = false,
			})

			-- 2. C++ 编译与运行函数 (保持不变)
			function _G.compile_and_run_cpp_interactive()
				if vim.bo.filetype ~= "cpp" then
					vim.notify("Error: Not a C++ file.", vim.log.levels.ERROR)
					return
				end
				vim.cmd("write")

				local dir_path = vim.fn.shellescape(vim.fn.expand("%:p:h"))
				local source_file_abs_path = vim.fn.shellescape(vim.fn.expand("%:p"))
				local executable_name_relative = vim.fn.shellescape(vim.fn.expand("%:t:r"))

				local cmd = string.format(
					"cd %s && clear && g++ -std=c++23 %s -o %s && ./%s",
					dir_path,
					source_file_abs_path,
					executable_name_relative,
					executable_name_relative
				)

				interactive_runner_term.on_open = function(term)
					term:send(cmd, true)
					vim.api.nvim_set_current_win(term.window)
					term.on_open = nil
				end

				interactive_runner_term:toggle()
			end

			-- ✨ 3. 新增：Python 运行函数
			function _G.run_python_interactive()
				if vim.bo.filetype ~= "python" then
					vim.notify("Error: Not a Python file.", vim.log.levels.ERROR)
					return
				end
				vim.cmd("write")

				local dir_path = vim.fn.shellescape(vim.fn.expand("%:p:h"))
				local source_file_abs_path = vim.fn.shellescape(vim.fn.expand("%:p"))

				-- Python 的命令更简单，直接用 python3 解释器运行即可
				local cmd = string.format("cd %s && clear && python3 %s", dir_path, source_file_abs_path)

				-- 复用同一个 on_open 逻辑
				interactive_runner_term.on_open = function(term)
					term:send(cmd, true)
					vim.api.nvim_set_current_win(term.window)
					term.on_open = nil
				end

				-- 复用同一个 toggle 行为
				interactive_runner_term:toggle()
			end

			-- 4. 绑定所有快捷键
			-- C++ 的快捷键
			vim.api.nvim_set_keymap(
				"n",
				"<leader>tc",
				"<cmd>lua _G.compile_and_run_cpp_interactive()<CR>",
				{ noremap = true, silent = true, desc = "Compile and run C++ file" }
			)

			-- ✨ Python 的快捷键
			vim.api.nvim_set_keymap(
				"n",
				"<leader>tp",
				"<cmd>lua _G.run_python_interactive()<CR>",
				{ noremap = true, silent = true, desc = "Run Python file" }
			)
		end,
	},
}
