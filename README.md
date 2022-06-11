# neotest-rspec

This plugin provides an [RSpec](https://rspec.info) adapter for the [Neotest](https://github.com/nvim-neotest/neotest) framework.
**It is currently a work in progress**. It will be transferred to the official neotest organisation (once it's been created).

## Installation

Using packer:

```lua
use({
  'nvim-neotest/neotest',
  requires = {
    ...,
    'olimorris/neotest-rspec',
  }
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

See neotest's documentation for more information on how to run tests.

## Feature requests

This repo is an initial starting point for the nvim Ruby community and I will try and add feature requests and solve bug reports where possible.
Hopefully once it is more stable users will be able to contribute to the project. For my own part I only intend to implement functionality that I use in daily workflow.

## Bug Reports

Please file any bug reports alongside code examples and I _will_ try and take a look. Otherwise please submit a PR. **This plugin is intended to be by the community for the community.**
