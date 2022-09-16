# neotest-rspec

[![Tests](https://github.com/olimorris/neotest-rspec/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/olimorris/neotest-rspec/actions/workflows/ci.yml)

This plugin provides an [RSpec](https://rspec.info) adapter for the [Neotest](https://github.com/nvim-neotest/neotest) framework.

<img width="1502" alt="Neotest and RSPec" src="https://user-images.githubusercontent.com/9512444/174159395-d4dc5e1e-9c3c-449f-b235-6fc8835fed5b.png">

## :package: Installation

Install the plugin using packer:

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

## :wrench: Configuration

The plugin may be configured as below:

```lua
adapters = {
  require('neotest-rspec')({
    rspec_cmd = function()
      return vim.tbl_flatten({
        "bundle",
        "exec",
        "rspec",
      })
    end
  }),
}
```

## :rocket: Usage

_NOTE_: All usages of `require('neotest').run.run` can be mapped to a command in your config (this is not included and should be done by yourself).

#### Test single function

To test a single test, hover over the test and run `require('neotest').run.run()`

#### Test file

To test a file run `require('neotest').run.run(vim.fn.expand('%'))`

#### Test directory

To test a directory run `require('neotest').run.run("path/to/directory")`

#### Test suite

To test the full test suite run `require('neotest').run.run("path/to/root_project")`
e.g. `require('neotest').run.run(vim.fn.getcwd())`, presuming that vim's directory is the same as the project root.

## :gift: Contributing

This project is maintained by the Neovim Ruby community. Please raise a PR if you are interested in adding new functionality or fixing any bugs. When submitting a bug, please include an example spec that can be tested.

To trigger the tests for the adapter, run:

```sh
./scripts/test
```

## :clap: Thanks

A special thanks to the following contributers:

- [Shanon McQuay](https://github.com/compactcode)
- [Brendan Mulholland](https://github.com/bmulholland)
- [Hussein Al Abry](https://github.com/zidhuss)
- [Paul Danelli](https://github.com/prdanelli)
- [Mr Ivanov](https://github.com/alxekb)
