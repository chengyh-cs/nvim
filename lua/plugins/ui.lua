return {
	-- NOTE: catppuccin
	{
		"catppuccin/nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		init = function()
			vim.cmd.colorscheme("catppuccin-mocha")
			vim.cmd.hi("Comment gui=none")
		end,
		config = function()
			local function set_transparent_float_highlights()
				local highlights = {
					NormalFloat = { bg = "NONE" },
					FloatBorder = { bg = "NONE" },
					FloatTitle = { bg = "NONE" },
					FloatFooter = { bg = "NONE" },
					NormalDark = { bg = "NONE" },
					Pmenu = { bg = "NONE" },
					PmenuExtra = { bg = "NONE" },
					PmenuKind = { bg = "NONE" },
					PmenuSbar = { bg = "NONE" },
					BlinkCmpMenu = { bg = "NONE" },
					BlinkCmpMenuBorder = { bg = "NONE" },
					BlinkCmpDoc = { bg = "NONE" },
					BlinkCmpDocBorder = { bg = "NONE" },
					NoiceCmdlinePopup = { bg = "NONE" },
					NoiceCmdlinePopupBorder = { bg = "NONE" },
					NoicePopup = { bg = "NONE" },
					NoicePopupBorder = { bg = "NONE" },
					TreesitterContext = { bg = "NONE" },
					TreesitterContextLineNumber = { bg = "NONE" },
				}

				for group, opts in pairs(highlights) do
					vim.api.nvim_set_hl(0, group, opts)
				end
			end

			require("catppuccin").setup({
				transparent_background = true,
				term_colors = true,
				integrations = {
					aerial = true,
					diffview = true,
					mini = {
						enabled = true,
						indentscope_color = "sky",
					},
					noice = true,
					-- overseer = true,
					telescope = {
						enabled = true,
						-- style = "nvchad",
					},
					neotree = true,
					which_key = true,
					treesitter = true,
					fzf = true,
					grug_far = true,
					notify = true,
					gitsigns = true,
					flash = true,
					blink_cmp = true,
					mason = true,
					snacks = true,
					alpha = true,
					cmp = true,
					dashboard = true,
					headlines = true,
					illuminate = true,
					indent_blankline = { enabled = true },
					leap = true,
					lsp_trouble = true,
					markdown = true,
					native_lsp = {
						enabled = true,
						underlines = {
							errors = { "undercurl" },
							hints = { "undercurl" },
							warnings = { "undercurl" },
							information = { "undercurl" },
						},
					},
					navic = { enabled = true, custom_bg = "lualine" },
					neotest = true,
					semantic_tokens = true,
					treesitter_context = true,
				},
				highlight_overrides = {
					mocha = function(mocha)
						return {
							CursorLineNr = { fg = mocha.yellow },
							TelescopeSelection = { bg = mocha.surface0 },
							TelescopeSelectionCaret = { fg = mocha.yellow, bg = mocha.surface0 },
							TelescopePromptPrefix = { fg = mocha.yellow },
						}
					end,
				},
			})

			local augroup = vim.api.nvim_create_augroup("transparent_float_highlights", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = augroup,
				callback = set_transparent_float_highlights,
			})

			set_transparent_float_highlights()
		end,
	},
	-- NOTE: gitsigns --> 文件变动行 左侧高亮
	{
		"lewis6991/gitsigns.nvim",
	},
	-- NOTE: lualine --> 下方状态行
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		event = "VeryLazy",
		opts = {
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				-- section_separators = { left = "", right = "" },
			},
			extensions = { "nvim-tree" },
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics", "filename" },
				lualine_c = {},
				lualine_x = {},
				lualine_y = {
					"filesize",
					"encoding",
					"filetype",
				},
				lualine_z = {
					"location",
				},
			},
		},
	},
	-- NOTE: noice --> 命令模式和消息提示 美化
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			--[[ {
			"rcarriga/nvim-notify", -- 可选依赖
			config = function()
				require("notify").setup({
					background_colour = "#1e1e2e", -- 配置 notify 的背景颜色
				})
			end,
		}, ]]
		},
	},
	-- NOTE: rainbow-delimiters --> 彩虹括号
	{
		"HiPhish/rainbow-delimiters.nvim",
		submodules = false,
		main = "rainbow-delimiters.setup",
		opts = {},
	},
	-- NOTE: indent-blankline --> 缩进显示
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		main = "ibl",
		opts = {
			indent = {
				highlight = {
					"RainbowRed",
					"RainbowYellow",
					"RainbowBlue",
					"RainbowOrange",
					"RainbowGreen",
					"RainbowViolet",
					"RainbowCyan",
				},
			},
		},
		config = function()
			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowGreen",
				"RainbowViolet",
				"RainbowCyan",
			}

			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
			end)

			require("ibl").setup({ indent = { highlight = highlight } })
		end,
	},
	-- NOTE: nvim-ufo --> 代码快折叠
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		opts = {
			provider_selector = function(_, _, _)
				return { "treesitter", "indent" }
			end,

			open_fold_hl_timeout = 0,
			fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local suffix = (" 󰁂 %d "):format(endLnum - lnum)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						-- str width returned from truncate() may less than 2nd argument, need padding
						if curWidth + chunkWidth < targetWidth then
							suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, { suffix, "MoreMsg" })
				return newVirtText
			end,
		},

		init = function()
			vim.o.foldenable = true
			vim.o.foldcolumn = "0" -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.opt.fillchars = {
				fold = " ",
				foldopen = "▾",
				foldsep = "│",
				foldclose = "▸",
			}
		end,

		config = function(_, opts)
			require("ufo").setup(opts)
			-- Ensure our ufo foldlevel is set for the buffer
			vim.api.nvim_create_autocmd("BufReadPre", {
				callback = function()
					vim.b.ufo_foldlevel = 0
				end,
			})

			---@param num integer Set the fold level to this number
			local set_buf_foldlevel = function(num)
				vim.b.ufo_foldlevel = num
				require("ufo").closeFoldsWith(num)
			end

			---@param num integer The amount to change the UFO fold level by
			local change_buf_foldlevel_by = function(num)
				local foldlevel = vim.b.ufo_foldlevel or 0
				-- Ensure the foldlevel can't be set negatively
				if foldlevel + num >= 0 then
					foldlevel = foldlevel + num
				else
					foldlevel = 0
				end
				set_buf_foldlevel(foldlevel)
			end

			-- Keymaps
			vim.keymap.set("n", "K", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end)

            -- stylua: ignore
            vim.keymap.set("n", "zM", function() set_buf_foldlevel(0) end, { desc = "[UFO] Close all folds" })
			vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "[UFO] Open all folds" })

			vim.keymap.set("n", "zm", function()
				local count = vim.v.count
				if count == 0 then
					count = 1
				end
				change_buf_foldlevel_by(-count)
			end, { desc = "[UFO] Fold More" })
			vim.keymap.set("n", "zr", function()
				local count = vim.v.count
				if count == 0 then
					count = 1
				end
				change_buf_foldlevel_by(count)
			end, { desc = "[UFO] Fold Less" })

			-- 99% sure `zS` isn't mapped by default
			vim.keymap.set("n", "zS", function()
				if vim.v.count == 0 then
					vim.notify("No foldlevel given to set!", vim.log.levels.WARN)
				else
					set_buf_foldlevel(vim.v.count)
				end
			end, { desc = "[UFO] Set foldlevel" })

			-- Delete some predefined keymaps as they are not compatible with nvim-ufo
			vim.keymap.set("n", "zE", "<NOP>", { desc = "Disabled" })
			vim.keymap.set("n", "zx", "<NOP>", { desc = "Disabled" })
			vim.keymap.set("n", "zX", "<NOP>", { desc = "Disabled" })
		end,
	},
}
