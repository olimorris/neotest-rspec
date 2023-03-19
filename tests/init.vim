set noswapfile

set rtp+=.
set rtp+=./misc/neotest
set rtp+=./misc/plenary
set rtp+=./misc/treesitter

lua << EOF
require("neotest").setup({
	adapters = {
		require("neotest-rspec")
	},
	consumers = {
		adapter_testing = require("neotest-rspec.consumers.adapter_testing")
	}
})
print(vim.loop.cwd())
vim.cmd([[set rtp?]])
EOF

runtime! plugin/plenary.vim
