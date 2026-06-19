all: format test

check:
	@echo Checking...
	stylua --check lua/ tests/ -f ./stylua.toml

format:
	@echo Formatting...
	@stylua tests/ lua/ -f ./stylua.toml

test: deps
	@echo Testing...
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

test_file: deps
	@echo Testing File...
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"


deps: deps/mini.nvim deps/nvim-treesitter deps/neotest deps/nvim-nio deps/plenary.nvim deps/parsers
	@echo Pulling...

deps/parsers:
	@mkdir -p deps/parsers

deps/mini.nvim:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/echasnovski/mini.nvim $@

deps/nvim-treesitter:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-treesitter/nvim-treesitter.git $@

deps/neotest:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-neotest/neotest $@

deps/nvim-nio:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-neotest/nvim-nio $@

deps/plenary.nvim:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-lua/plenary.nvim.git $@
