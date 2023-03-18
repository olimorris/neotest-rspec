set rtp+=.
set rtp+=./misc/neotest
set rtp+=./misc/plenary
set rtp+=./misc/treesitter

lua << EOF
require("nvim-treesitter.configs").setup({
	ensure_installed = "ruby",
})
require("neotest").setup({
	adapters = {
		require("neotest-rspec"),
	},
	consumers = {
		rspec_testing = require("neotest-rspec.consumers.rspec_testing")
	}
})
EOF

runtime! plugin/plenary.vim

