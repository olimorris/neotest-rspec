vim.cmd([[let &rtp.=','.getcwd()]])
vim.cmd("set rtp+=deps/plenary.nvim")
vim.cmd("set rtp+=deps/nvim-treesitter")
vim.cmd("set rtp+=deps/neotest")
vim.cmd("set rtp+=deps/nvim-nio")

-- Point Tree-sitter to the pre-installed parsers
require("nvim-treesitter").setup({
  install_dir = "deps/parsers",
})
