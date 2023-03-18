NEOTEST_DIR = misc/neotest
NEOTEST_URL = https://github.com/nvim-neotest/neotest
PLENARY_DIR = misc/plenary
PLENARY_URL = https://github.com/nvim-lua/plenary.nvim
TEST_DIR = tests/run_tests_spec.lua

test: $(NEOTEST_DIR) $(PLENARY_DIR)
	nvim \
		--headless \
		--noplugin \
		-u tests/init.vim \
		-c "PlenaryBustedFile $(TEST_DIR)"

$(NEOTEST_DIR):
	git clone --depth=1 --no-single-branch $(NEOTEST_URL) $(NEOTEST_DIR)
	@rm -rf $(NEOTEST_DIR)/.git

$(PLENARY_DIR):
	git clone --depth=1 --no-single-branch $(PLENARY_URL) $(PLENARY_DIR)
	@rm -rf $(PLENARY_DIR)/.git
