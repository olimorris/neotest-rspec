# neotest-rspec

A Neovim plugin adapter that integrates RSpec testing with the Neotest framework.

## Key Files

- `lua/neotest-rspec/init.lua` - Main adapter implementation (root detection, test discovery, command building, results parsing)
- `lua/neotest-rspec/utils.lua` - Utility functions (ID generation, JSON parsing)
- `lua/neotest-rspec/config.lua` - Configuration defaults
- `lua/neotest-rspec/consumers/adapter_testing.lua` - Testing utilities

## Development

```bash
make format    # Format code with stylua
make test      # Run tests with MiniTest
make check     # Check formatting without applying changes
```

## References

- [Neotest](https://raw.githubusercontent.com/nvim-neotest/neotest/refs/heads/master/README.md) - Framework documentation
