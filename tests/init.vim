set rtp+=.
set rtp+=./misc/neotest
set rtp+=./misc/plenary
set rtp+=./misc/treesitter

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

runtime! plugin/plenary.vim

