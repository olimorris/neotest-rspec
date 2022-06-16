# neotest-rspec

This plugin provides an [RSpec](https://rspec.info) adapter for the [Neotest](https://github.com/nvim-neotest/neotest) framework.

## Installation

Using packer:

```lua
use({
  'nvim-neotest/neotest',
  requires = {
    ...,
    'olimorris/neotest-rspec',
  },
  config = function()
    require('neotest').setup({
      ...,
      adapters = {
        require('neotest-rspec'),
      }
    })
  end
})
```

## Usage

_NOTE_: All usages of `require('neotest').run.run` can be mapped to a command in your config (this is not included and should be done by yourself).

#### Test single function

To test a single test hover over the test and run `require('neotest').run.run()`

#### Test file

To test a file run `require('neotest').run.run(vim.fn.expand('%'))`

#### Test directory

To test a directory run `require('neotest').run.run("path/to/directory")`

#### Test suite

To test the full test suite run `require('neotest').run.run("path/to/root_project")`
e.g. `require('neotest').run.run(vim.fn.getcwd())`, presuming that vim's directory is the same as the project root.

## Contributing

This project is maintained by the nvim ruby community. Please raise a PR if you are interested in adding new functionality or fixing any bugs. If you are unsure of how this plugin works please read the [writing adapters](https://github.com/nvim-neotest/neotest#writing-adapters) section of the Neotest README.

If you are new to `lua` please follow any of the following resources:

- https://learnxinyminutes.com/docs/lua/
- https://www.lua.org/manual/5.1/
- https://github.com/nanotee/nvim-lua-guide
