NEOTEST_DIR = misc/neotest
NEOTEST_URL = https://github.com/nvim-neotest/neotest
PLENARY_DIR = misc/plenary
PLENARY_URL = https://github.com/nvim-lua/plenary.nvim
TREESITTER_DIR = misc/treesitter
TREESITTER_URL = https://github.com/nvim-treesitter/nvim-treesitter
TEST_DIR = tests/

test: $(NEOTEST_DIR) $(PLENARY_DIR) $(TREESITTER_DIR)
	echo "===> Testing:"
	nvim --headless --clean \
	-u tests/init.vim \
	-c "PlenaryBustedDirectory $(TEST_DIR) {minimal_init = 'tests/init.vim'}"

$(NEOTEST_DIR):
	git clone --depth=1 --no-single-branch $(NEOTEST_URL) $(NEOTEST_DIR)
	@rm -rf $(NEOTEST_DIR)/.git

$(PLENARY_DIR):
	git clone --depth=1 --no-single-branch $(PLENARY_URL) $(PLENARY_DIR)
	@rm -rf $(PLENARY_DIR)/.git

$(TREESITTER_DIR):
	git clone --depth=1 --no-single-branch $(TREESITTER_URL) $(TREESITTER_DIR)
	@rm -rf $(TREESITTER_DIR)/.git
