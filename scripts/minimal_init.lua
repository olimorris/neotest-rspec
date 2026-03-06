vim.cmd([[let &rtp.=','.getcwd()]])
vim.cmd("set rtp+=deps/mini.nvim")
vim.cmd("set rtp+=deps/plenary.nvim")
vim.cmd("set rtp+=deps/nvim-treesitter")
vim.cmd("set rtp+=deps/neotest")
vim.cmd("set rtp+=deps/nvim-nio")

-- Ensure mini.test is available
require("mini.test").setup()

-- Install and setup Tree-sitter
require("nvim-treesitter").setup({
  install_dir = "deps/parsers",
})

require("nvim-treesitter")
  .install({
    "ruby",
  }, { summary = true, generate = true })
  :pwait(300000)
