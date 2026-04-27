return {
	-- NOTE: mason
	{
		"williamboman/mason.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig",
		},
		config = function()
			-- 基础的 mason 设置
			require("mason").setup()

			local mason_lspconfig = require("mason-lspconfig")
			local python = require("core.python")
			local pyright_root_markers = {
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
				"pyrightconfig.json",
				".git",
			}

			vim.api.nvim_create_user_command("PyrightPythonPath", function()
				local clients = vim.lsp.get_clients({
					bufnr = vim.api.nvim_get_current_buf(),
					name = "pyright",
				})
				local client = clients[1]
				local python_path = python.get_client_python_path(client)

				if python_path then
					vim.notify("Pyright Python: " .. python_path, vim.log.levels.INFO)
					return
				end

				vim.notify("Current buffer has no active pyright client", vim.log.levels.WARN)
			end, {
				desc = "Show the python interpreter path used by pyright",
			})

			-- 定义每个 LSP 的特殊配置
			-- 这个 table 只存放数据，不进行任何函数调用
			local server_configs = {
				["lua_ls"] = { -- 注意：lspconfig 中 lua-language-server 的名字是 lua_ls
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								checkThirdParty = false, -- 避免检查 workspace 中其他插件的代码
							},
						},
					},
				},
				["pyright"] = {
					root_markers = pyright_root_markers,
					workspace_required = false,
					root_dir = function(bufnr, on_dir)
						on_dir(python.get_python_root(bufnr))
					end,
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "basic",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "workspace",
								-- autoImportCompletions = true, -- 建议开启
							},
						},
					},
					before_init = function(_, new_config)
						python.apply_python_path(new_config)
					end,
				},
				["clangd"] = {
					cmd = { "clangd", "--background-index", "--clang-tidy" },
					filetypes = { "c", "cpp", "objc", "objcpp" },
				},
			}

			local capabilities = require("blink.cmp").get_lsp_capabilities()

			for server_name, server_opts in pairs(server_configs) do
				local final_opts = vim.tbl_deep_extend("force", {
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						-- 在这里设置 on_attach 相关的功能，比如快捷键
						client.server_capabilities.documentFormattingProvider = true
						client.server_capabilities.documentRangeFormattingProvider = true

						if client.name == "pyright" then
							python.sync_python_client(client)
						end
					end,
				}, server_opts)

				vim.lsp.config(server_name, final_opts)
				vim.lsp.enable(server_name)
			end

			-- mason-lspconfig 只负责安装，不再使用已移除的 handlers 配置
			mason_lspconfig.setup({
				ensure_installed = vim.tbl_keys(server_configs),
				automatic_enable = false,
			})

			-- 你其他的 lsp 诊断信息配置 (保持不变)
			vim.diagnostic.config({
				virtual_text = true,
				update_in_insert = true,
			})
		end,
	},
	-- NOTE: blink --> 补全
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		event = "VeryLazy",
		opts = {
			completion = {
				documentation = {
					auto_show = true,
				},
			},
			keymap = {
				preset = "super-tab",
			},
			sources = {
				default = { "path", "snippets", "buffer", "lsp" },
			},
			cmdline = {
				sources = function()
					local cmd_type = vim.fn.getcmdtype()
					if cmd_type == "/" then
						return { "buffer" }
					end
					if cmd_type == ":" then
						return { "cmdline" }
					end
					return {}
				end,
				keymap = {
					preset = "super-tab",
				},
				completion = {
					menu = {
						auto_show = true,
					},
				},
			},
		},
	},
	-- NOTE: lspsaga --> 增强 lsp 功能
	{
		"nvimdev/lspsaga.nvim",
		cmd = "Lspsaga",
		opts = {
			finder = {
				keys = {
					toggle_or_open = "<CR>",
				},
			},
		},
		keys = {
			{ "<leader>lr", ":Lspsaga rename<CR>", desc = "[lspsaga] rename" },
			{ "<leader>ld", ":Lspsaga goto_definition<CR>", desc = "[lspsaga] goto_definition" },
			{ "<leader>lh", ":Lspsaga hover_doc<CR>", desc = "[lspsaga] hover_doc" },
			{ "<leader>lR", ":Lspsaga finder<CR>", desc = "[lspsaga] finder" },
			{ "<leader>ln", ":Lspsaga diagnostic_jump_next<CR>", desc = "[lspsaga] diagnostic_jump_next" },
			{ "<leader>lp", ":Lspsaga diagnostic_jump_prev<CR>", desc = "[lspsaga] diagnostic_jump_prev" },
			{
				"<leader>le",
				function()
					vim.diagnostic.open_float(nil, {
						scope = "line",
						border = "rounded",
						focusable = true,
					})
				end,
				desc = "[diagnostic] line error",
			},
		},
	},
	-- NOTE: nvim-conda
	{
		"kmontocam/nvim-conda",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
}
