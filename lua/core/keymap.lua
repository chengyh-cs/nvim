vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.keymap.set({ "n", "i" }, "<D-z>", "<Cmd>undo<CR>", { silent = true })
vim.keymap.set({ "n", "x", "o" }, "<S-H>", "^", { desc = "Start of line" })
vim.keymap.set({ "n", "x", "o" }, "<S-L>", "$", { desc = "End of line" })

-- 终端模式下，esc 切换回 normal 模式
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

-- 在 ~/.config/nvim/init.lua 或你的 lua/config/keymaps.lua 文件中
vim.keymap.set('n', '<M-h>', '<C-w>h', { desc = 'Go to Left Window (Alt+h)' })
vim.keymap.set('n', '<M-j>', '<C-w>j', { desc = 'Go to Down Window (Alt+j)' })
vim.keymap.set('n', '<M-k>', '<C-w>k', { desc = 'Go to Up Window (Alt+k)' })
vim.keymap.set('n', '<M-l>', '<C-w>l', { desc = 'Go to Right Window (Alt+l)' })

-- tab
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "多行缩减缩进 (visual mode)" })
vim.keymap.set("v", "<Tab>", ">gv", { desc = "多行增加缩进 (visual mode)" })
