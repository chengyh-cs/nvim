return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = false },
		image = {
			enabled = true,
			convert = {
				magick = {
					math = {
						"-density",
						192,
						"{src}[0]",
						"-trim",
						"-bordercolor",
						"transparent",
						"-border",
						"0x6",
					},
				},
			},
			doc = {
				enabled = true,
				inline = true,
				float = true,
				max_width = 80,
				max_height = 40,
			},
			math = {
				latex = {
					font_size = "scriptsize",
				},
			},
		},
		indent = { enabled = true },
		input = { enabled = true },
		picker = {
			enabled = true,
			layout = {
				preset = "default",
			},
			win = {
				input = {
					keys = {
						["<c-j>"] = { "list_down", mode = { "i", "n" } },
						["<c-k>"] = { "list_up", mode = { "i", "n" } },
					},
				},
				list = {
					keys = {
						["<c-j>"] = "list_down",
						["<c-k>"] = "list_up",
					},
				},
			},
			sources = {
				recent = {
					win = {
						input = {
							keys = {
								["<c-j>"] = { "list_down", mode = { "i", "n" } },
								["<c-k>"] = { "list_up", mode = { "i", "n" } },
							},
						},
						list = {
							keys = {
								["<c-j>"] = "list_down",
								["<c-k>"] = "list_up",
							},
						},
					},
				},
			},
		},
		notifier = {
			enabled = true,
			style = "notification",
		},
		lazygit = {
			enabled = true,
			configure = false,
		},
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		{
			"<leader>lg",
			function()
				Snacks.lazygit({ cwd = Snacks.git.get_root() })
			end,
			desc = "[snacks-lazygit] Lazygit current buffer",
		},
		{
			"<leader>bc",
			function()
				Snacks.bufdelete()
			end,
			desc = "[snacks] Delete Buffer",
		},
		{
			"<leader>bC",
			function()
				Snacks.bufdelete.other()
			end,
			desc = "[snacks] Delete Other Buffers",
		},
		-- {
		-- 	"<leader>nh",
		-- 	function()
		-- 		Snacks.notifier.show_history()
		-- 	end,
		-- 	desc = "Notification History",
		-- },
		-- {
		-- 	"<leader>gb",
		-- 	function()
		-- 		Snacks.git.blame_line()
		-- 	end,
		-- 	desc = "Git Blame Line",
		-- },
		{
			"<leader>f/",
			function()
				Snacks.picker.search_history()
			end,
			desc = "[snacks] Search history",
		},
		{
			"<leader>fj",
			function()
				Snacks.picker.jumps()
			end,
			desc = "[snacks] Search jump list",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.smart()
			end,
			desc = "[snacks] Smart Find Files",
		},
		{
			"<leader>fF",
			function()
				Snacks.picker.smart({
					ignored = true,
				})
			end,
			desc = "[snacks] Smart Find Files",
		},
		{
			"<leader>fo",
			function()
				Snacks.picker.recent()
			end,
			desc = "[snacks] Smart Find Files",
		},
		{
			"<leader><leader>",
			function()
				Snacks.picker.buffers({
					sort_lastused = true,
				})
			end,
			desc = "[snacks] Buffers",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help({
					layout = "dropdown",
				})
			end,
			desc = "[snacks] Help Pages",
		},
		{
			"<leader>fL",
			function()
				Snacks.picker.picker_layouts()
			end,
			desc = "[snacks] Picker layout",
		},
		{
			"<leader>fk",
			function()
				Snacks.picker.keymaps({
					layout = "dropdown",
				})
			end,
			desc = "[snacks] Keymaps",
		},
		{
			"<leader>fm",
			function()
				Snacks.picker.marks()
			end,
			desc = "[snacks] Marks",
		},
		{
			"<leader>fn",
			function()
				Snacks.picker.notifications()
			end,
			desc = "[snacks] Notification History",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "[snacks] Find Config File",
		},
		{
			"<leader>fw",
			function()
				Snacks.picker.grep()
			end,
			desc = "[snacks] Grep",
		},
		{
			"<leader>fW",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "[snacks] Grep Word Under Cursor",
			mode = { "n", "x" },
		},
		{
			"<leader>fa",
			function()
				Snacks.picker.autocmds()
			end,
			desc = "[snacks] Find autocmds",
			mode = { "n" },
		},
		{
			"<leader>ls",
			function()
				local bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr })

				local function has_lsp_symbols()
					for _, client in ipairs(clients) do
						if client.server_capabilities.documentSymbolProvider then
							return true
						end
					end
					return false
				end

				local picker_opts = {
					layout = "left",
					tree = true,
					on_show = function()
						vim.cmd.stopinsert()
					end,
				}
				if has_lsp_symbols() then
					Snacks.picker.lsp_symbols(picker_opts)
				else
					Snacks.picker.treesitter()
					-- require('aerial').snacks_picker(picker_opts)
				end
			end,
			desc = "[snacks] LSP Symbols",
		},
		{
			"<leader>fs",
			function()
				local bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr })

				local function has_lsp_symbols()
					for _, client in ipairs(clients) do
						if client.server_capabilities.documentSymbolProvider then
							return true
						end
					end
					return false
				end

				local picker_opts = {
					layout = "left",
					tree = true,
				}
				if has_lsp_symbols() then
					Snacks.picker.lsp_symbols(picker_opts)
				else
					Snacks.picker.treesitter()
					-- require('aerial').snacks_picker(picker_opts)
				end
			end,
			desc = "[snacks] LSP Symbols",
		},
		{
			"<leader>fS",
			function()
				Snacks.picker.lsp_workspace_symbols({
					layout = "dropdown",
				})
			end,
			desc = "[snacks] LSP Workspace Symbols",
		},
		{
			"<leader>fi",
			function()
				Snacks.picker.icons()
			end,
			desc = "[snacks] Icons",
		},
		{
			"<leader>fd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "[snacks] Diagnostics",
		},
		{
			"<leader>fT",
			function()
				---@diagnostic disable-next-line: undefined-field
				Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME", "HACK", "NOTE" }, layout = "select" })
			end,
			desc = "[snacks] Todo/Fix/Fixme",
		},
		-- {
		-- 	"<leader>ft",
		-- 	function()
		-- 		Snacks.picker.grep_buffers({
		-- 			finder = "grep",
		-- 			format = "file",
		-- 			prompt = " ",
		-- 			search = "^\\s*- \\[ \\]",
		-- 			regex = true,
		-- 			live = false,
		-- 			args = { "--no-ignore" },
		-- 			on_show = function()
		-- 				vim.cmd.stopinsert()
		-- 			end,
		-- 			buffers = false,
		-- 			supports_live = false,
		-- 			layout = "ivy",
		-- 		})
		-- 	end,
		-- 	desc = "[snacks] Search for incomplete tasks",
		-- },
		{
			"<leader>fH",
			function()
				Snacks.picker.highlights()
			end,
			desc = "[snacks] Show highlights",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "[snacks] Git branches",
		},
		{
			"<leader>fp",
			function()
				Snacks.picker.projects()
			end,
			desc = "[snacks] Projects",
		},
	},
}
