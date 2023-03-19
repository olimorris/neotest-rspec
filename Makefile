NEOTEST_DIR = misc/neotest
PLENARY_DIR = misc/plenary
TREESITTER_DIR = misc/treesitter
TEST_DIR = tests/unit

ci: $(TREESITTER_DIR)
	nvim --headless -c 'TSInstallSync! ruby | quit' -c quit

test: $(NEOTEST_DIR) $(PLENARY_DIR) $(TREESITTER_DIR)
	nvim --headless --clean \
	-u tests/init.vim \
	-c "PlenaryBustedDirectory $(TEST_DIR) { minimal_init = 'tests/init.vim' }"

$(NEOTEST_DIR):
	git clone --depth=1 --no-single-branch https://github.com/nvim-neotest/neotest $(NEOTEST_DIR)
	@rm -rf $(NEOTEST_DIR)/.git

$(PLENARY_DIR):
	git clone --depth=1 --no-single-branch https://github.com/nvim-lua/plenary.nvim $(PLENARY_DIR)
	@rm -rf $(PLENARY_DIR)/.git

$(TREESITTER_DIR):
	git clone --depth=1 --no-single-branch https://github.com/nvim-treesitter/nvim-treesitter $(TREESITTER_DIR)
	@rm -rf $(TREESITTER_DIR)/.git
