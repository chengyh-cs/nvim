return {
	-- NOTE: nvim-autopairs --> 自动补全括号
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	-- NOTE: Comment --> 快速注释
	{
		"numToStr/Comment.nvim",
		keys = {
			{
				"<leader>/",
				function()
					require("Comment.api").toggle.linewise.current()
				end,
				mode = "n",
				desc = "[Comment] Comment current line",
				e,
			},
			{
				"<leader>/",
				"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
				mode = "v",
				desc = "Comment current line",
			},
		},
		config = true,
	},
	-- NOTE: grug-far --> 查找替换
	{
		"MagicDuck/grug-far.nvim",
		opts = {
			headerMaxWidth = 80,
			startFolded = false,
		},
		cmd = "GrugFar",
		keys = {
			{
				"<leader>sr",
				function()
					local grug = require("grug-far")
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					grug.open({
						transient = true,
						prefills = {
							filesFilter = ext and ext ~= "" and "*." .. ext or nil,
						},
					})
				end,
				mode = { "n", "v" },
				desc = "Search and Replace",
			},
		},
	},
	-- NOTE: none-ls --> 代码格式化
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"vim-lua/plenary.nvim",
		},
		event = "VeryLazy",
		config = function()
			local registry = require("mason-registry")
			local function install(name)
				local success, package = pcall(registry.get_package, name)
				if success and not package:is_installed() then
					package:install()
				end
			end
			install("stylua")
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
				},
			})
		end,
		keys = {
			{
				"<leader>lf",
				vim.lsp.buf.format,
				desc = "[none-ls] CodeFormatting",
			},
		},
	},
	-- NOTE: mini.surround --> + 括号
	{
		"echasnovski/mini.surround",
		version = "*",
		event = "BufReadPost",
		config = true,
		keys = {
			-- Disable the vanilla `s` keybinding
			{ "s", "<NOP>", mode = { "n", "x", "o" } },
		},
	},
	-- NOTE: code-runner --> 代码运行（好像还有点问题）
	{
		"CRAG666/code_runner.nvim",
		version = "*",
		dependencies = {
			-- 可选：添加相关依赖，例如调试或终端插件
			"nvim-lua/plenary.nvim",
		},
		event = "VeryLazy",
		opts = {
			filetype = {
				python = "python3 -u",
				cpp = { "g++ $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt" },
				java = "javac $fileName && java $fileNameWithoutExt",
				javascript = "node",
			},
		},
	},
	-- NOTE: smartyank --> 复制内容到系统 clipboard
	{
		"ibhagwan/smartyank.nvim",
		event = { "BufWinEnter" },
		opts = {
			highlight = {
				timeout = 200, -- timeout for clearing the highlight
			},
			clipboard = {
				enabled = true,
			},
			osc52 = {
				silent = true, -- true to disable the "n chars copied" echo
			},
		},
	},
	-- NOTE: trim --> 自动删除行末空格
	{
		"cappyzawa/trim.nvim",
		event = "BufWritePre",
		opts = {},
	},
	-- NOTE: flash --> 快速跳转
	{
		"folke/flash.nvim",
		event = "BufReadPost",
		opts = {
			label = {
				rainbow = {
					enabled = true,
					shade = 1,
				},
			},
			modes = {
				char = {
					enabled = false,
				},
			},
			jump = {
				pos = "end",
			},
		},
		keys = {
            -- stylua: ignore
            {
                "<leader>jj",
                mode = { "n", "x", "o" },
                function()
                    require("flash").jump()
                end,
                desc = "[Flash] Jump"
            },
			-- -- stylua: ignore
			-- { "<leader>F", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "[Flash] Treesitter"        },
			-- -- stylua: ignore
			-- { "<leader>F", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "[Flash] Treesitter Search" },
			-- -- stylua: ignore
			-- { "<c-f>",     mode = { "c" },           function() require("flash").toggle() end,            desc = "[Flash] Toggle Search"     },
			-- {
			-- 	"<leader>j",
			-- 	mode = { "n", "x", "o" },
			-- 	function()
			-- 		require("flash").jump({
			-- 			search = { mode = "search", max_length = 0 },
			-- 			label = { after = { 0, 0 }, matches = false },
			-- 			jump = { pos = "end" },
			-- 			pattern = "^\\s*\\S\\?", -- match non-whitespace at start plus any character (ignores empty lines)
			-- 		})
			-- 	end,
			-- 	desc = "[Flash] Line jump",
			-- },
			-- {
			-- 	"<leader>k",
			-- 	mode = { "n", "x", "o" },
			-- 	function()
			-- 		require("flash").jump({
			-- 			search = { mode = "search", max_length = 0 },
			-- 			label = { after = { 0, 0 }, matches = false },
			-- 			jump = { pos = "end" },
			-- 			pattern = "^\\s*\\S\\?", -- match non-whitespace at start plus any character (ignores empty lines)
			-- 		})
			-- 	end,
			-- 	desc = "[Flash] Line jump",
			-- },
		},
	},
	-- NOTE: todo-comments.nvim --> 注释高亮：FIX、TODO、NOTE
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"folke/snacks.nvim",
		},
		event = "VeryLazy",
        -- stylua: ignore
        keys = {},
		config = true,
	},
	-- NOTE: multicursor --> 多光标编辑
	{
		"jake-stewart/multicursor.nvim",
		keys = {
			{ "<C-n>" },
			{ "<leader>s" },
			{ "<leader>N" },
			{ "<leader>S" },
			{ "<leader>A" },
			{ "<C-q>" },
			{ "<leader>gv" },
			{ "<C-LeftMouse>" },
			{ "M", mode = "v" },
			{ "I", mode = "v" },
			{ "A", mode = "v" },
		},
		branch = "1.0",
		config = function()
			local mc = require("multicursor-nvim")
			mc.setup()

			local set = vim.keymap.set

			set({ "n", "v" }, "<C-n>", function()
				mc.matchAddCursor(1)
			end)
			set({ "n", "v" }, "<leader>s", function()
				mc.matchSkipCursor(1)
			end)
			set({ "n", "v" }, "<leader>N", function()
				mc.matchAddCursor(-1)
			end)
			set({ "n", "v" }, "<leader>S", function()
				mc.matchSkipCursor(-1)
			end)

			set({ "n", "v" }, "<leader>A", mc.matchAllAddCursors)

			set({ "n", "v" }, "<left>", mc.nextCursor)
			set({ "n", "v" }, "<right>", mc.prevCursor)

			set("n", "<c-leftmouse>", mc.handleMouse)

			set({ "n", "v" }, "<c-q>", mc.toggleCursor)

			set("n", "<esc>", function()
				if not mc.cursorsEnabled() then
					mc.enableCursors()
				elseif mc.hasCursors() then
					mc.clearCursors()
				else
					vim.cmd("nohlsearch")
				end
			end)

			set("n", "<leader>gv", mc.restoreCursors)

			set("v", "I", mc.insertVisual)
			set("v", "A", mc.appendVisual)

			set("v", "M", mc.matchCursors)

			set({ "v", "n" }, "<c-i>", mc.jumpForward)
			set({ "v", "n" }, "<c-o>", mc.jumpBackward)

			-- 自定义光标外观。
			local hl = vim.api.nvim_set_hl
			hl(0, "MultiCursorCursor", { link = "Cursor" })
			hl(0, "MultiCursorVisual", { link = "Visual" })
			hl(0, "MultiCursorSign", { link = "SignColumn" })
			hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
			hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
			hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
		end,
	},
	-- NOTE: markview --> markdown 预览
	-- {
	-- 	-- For `plugins/markview.lua` users.
	-- 	"OXY2DEV/markview.nvim",
	-- 	lazy = false,
	--
	-- 	-- For `nvim-treesitter` users.
	-- 	priority = 49,
	--
	-- 	-- For blink.cmp's completion
	-- 	-- source
	-- 	-- dependencies = {
	-- 	--     "saghen/blink.cmp"
	-- 	-- },
	-- },
	-- NOTE: render-markdown --> markdown 预览
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			latex = { enabled = false },
			completions = {
				blink = { enabled = true },
				lsp = { enabled = true },
			},
		},
	},
	-- NOTE: nvim-treesitter-context --> 函数名悬停
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesitter-context").setup({
				enable = true,
				throttle = true,
				max_lines = 3,
				mode = "topline",
				separator = nil,
				patterns = {
					default = {
						"function",
						"method",
						"for",
						"while",
						"if",
						"else",
						"elseif",
						"match",
						"try",
						"catch",
						"finally",
						"struct",
						"class",
						"enum",
						"union",
						"trait",
						"impl",
						"loop",
						"switch",
					},
					lua = { "function" },
					python = { "function", "class" },
					c = { "function_definition", "for_statement", "if_statement", "while_statement" },
				},
				-- 自定义文本格式
				-- format_context_line = "  %s",
			})
		end,
	},
}
