set noswapfile

set rtp+=.
set rtp+=./misc/neotest
set rtp+=./misc/plenary
set rtp+=./misc/treesitter

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.lua

lua << EOF
require("neotest").setup({
	adapters = {
		require("neotest-rspec"),
	},
	consumers = {
		adapter_testing = require("neotest-rspec.consumers.adapter_testing")
	}
})
EOF
