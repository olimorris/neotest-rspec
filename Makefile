NEOTEST_DIR = misc/neotest
PLENARY_DIR = misc/plenary
TREESITTER_DIR = misc/treesitter
TEST_DIR = tests/unit

test: test_core test_rspec

test_core: $(NEOTEST_DIR) $(PLENARY_DIR) $(TREESITTER_DIR)
	nvim --headless --clean \
	-u tests/minimal_init.lua \
	-c "PlenaryBustedDirectory $(TEST_DIR)/core { minimal_init = 'tests/minimal_init.lua' }"

test_rspec: $(NEOTEST_DIR) $(PLENARY_DIR) $(TREESITTER_DIR)
	nvim --headless --clean \
	-u tests/minimal_init.lua \
	-c "PlenaryBustedDirectory $(TEST_DIR)/rspec { minimal_init = 'tests/minimal_init.lua' }"

$(NEOTEST_DIR):
	git clone --depth=1 --no-single-branch https://github.com/nvim-neotest/neotest $(NEOTEST_DIR)
	@rm -rf $(NEOTEST_DIR)/.git

$(PLENARY_DIR):
	git clone --depth=1 --no-single-branch https://github.com/nvim-lua/plenary.nvim $(PLENARY_DIR)
	@rm -rf $(PLENARY_DIR)/.git

$(TREESITTER_DIR):
	git clone --depth=1 --no-single-branch https://github.com/nvim-treesitter/nvim-treesitter $(TREESITTER_DIR)
	@rm -rf $(TREESITTER_DIR)/.git
