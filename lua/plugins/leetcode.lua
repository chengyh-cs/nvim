return {
	-- NOTE: leetcode.nvim
	{
		"kawre/leetcode.nvim",
		build = ":TSUpdate html", -- 若有nvim-treesitter则执行
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			lang = "python3", -- 默认编程语言
			cn = {
				enabled = true, -- 启用中国版leetcode.cn
				translator = true, -- 启用题目翻译
			},
			storage = {
				home = vim.fn.stdpath("data") .. "/leetcode", -- 数据存储
				cache = vim.fn.stdpath("cache") .. "/leetcode", -- 缓存目录
			},
			injector = {
				["python3"] = {
					imports = function(default_imports)
						vim.list_extend(default_imports, { "from .leetcode import *" })
						return default_imports
					end,
					after = { "def test():", "    print('test')" }, -- 测试代码模板
				},
			},
            picker = { provider = "telescope" }, -- 支持telescope/fzf-lua/snacks-picker
		},
	},
}
