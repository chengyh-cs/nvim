return {
  "github/copilot.vim",
  config = function()
    -- 可选：启动后自动登录
    vim.g.copilot_no_tab_map = true
    vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")', {silent = true, expr = true})
  end,
}
