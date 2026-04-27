local lazypath = vim.fn.stdpath("data") .. "lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

-- 将 lazypath 设置为运行时路径
-- rtp (runtime path)
-- nvim 进行路径搜索时，除了已有路径，还会从 prepend 路径中进行查找
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
})
