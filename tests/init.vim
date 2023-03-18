set rtp+=.
set rtp+=./misc/plenary
set rtp+=./misc/neotest

lua << EOF
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

