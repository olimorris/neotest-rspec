# neotest-rspec

<!-- [![Tests](https://github.com/olimorris/neotest-rspec/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/olimorris/neotest-rspec/actions/workflows/ci.yml) -->
This plugin provides an [RSpec](https://rspec.info) adapter for the [Neotest](https://github.com/nvim-neotest/neotest) framework.

<img width="1502" alt="Neotest and RSPec" src="https://user-images.githubusercontent.com/9512444/174159395-d4dc5e1e-9c3c-449f-b235-6fc8835fed5b.png">

## :package: Installation

Install with the package manager of your choice:

**Lazy**

```lua
{
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    ...,
    "olimorris/neotest-rspec",
  },
  config = function()
    require("neotest").setup({
      ...,
      adapters = {
        require("neotest-rspec")
      },
    }
  end
}
```

**Packer**

```lua
use({
  "nvim-neotest/neotest",
  requires = {
    ...,
    "olimorris/neotest-rspec",
  },
  config = function()
    require("neotest").setup({
      ...,
      adapters = {
        require("neotest-rspec"),
      }
    })
  end
})
```

## :wrench: Configuration

### Default configuration

> **Note**: You only need to the call the `setup` function if you wish to change any of the defaults.

<details>
  <summary>Click to see the default configuration</summary>

```lua
adapters = {
  require("neotest-rspec")({
    rspec_cmd = function()
      return vim.tbl_flatten({
        "bundle",
        "exec",
        "rspec",
      })
    end,
    root_files = { "Gemfile", ".rspec", ".gitignore" },
    filter_dirs = { ".git", "node_modules" }
  }),
}
```

</details>

### The test command

The command used to run tests can be changed via the `rspec_cmd` option:

```lua
require("neotest-rspec")({
  rspec_cmd = function()
    return vim.tbl_flatten({
      "bundle",
      "exec",
      "rspec",
    })
  end
})
```

### Setting the root directory

For Neotest adapters to work, they need to define a project root whereby the process of discovering tests can take place. By default, the adapter looks for a `Gemfile`, `.rspec` or `.gitignore` file. These can be added to with:

```lua
require("neotest-rspec")({
  root_files = { "README.md" }
})
```

### Filtering directories

By default, the adapter will search for `_spec.rb` files in all dirs in the root with the exception of `node_modules` and `.git`. In a big project, this may result in slow performance. You can also add additional directories to filter out:

```lua
require("neotest-rspec")({
  filter_dirs = { "my_custom_dir" }
})
```

### Running tests in a docker container

This is not yet directly support by neotest, but you can accomplish this using a shell script as your rspec command. See [this comment](https://github.com/nvim-neotest/neotest/issues/89#issuecomment-1338141432) for an example.

## :rocket: Usage

> **Note**: All usages of `require("neotest").run.run` can be mapped to a command in your config (this is not included and should be done by yourself).

#### Test single function

To test a single test, hover over the test and run `require("neotest").run.run()`

#### Test file

To test a file run `require("neotest").run.run(vim.fn.expand("%"))`

#### Test directory

To test a directory run `require("neotest").run.run("path/to/directory")`

#### Test suite

To test the full test suite run `require("neotest").run.run("path/to/root_project")`
e.g. `require("neotest").run.run(vim.fn.getcwd())`, presuming that vim's directory is the same as the project root.

## :gift: Contributing

This project is maintained by the Neovim Ruby community. Please raise a PR if you are interested in adding new functionality or fixing any bugs. When submitting a bug, please include an example spec that can be tested.

To trigger the tests for the adapter, run:

```sh
make test
```

