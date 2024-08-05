# neotest-rspec

<!-- [![Tests](https://github.com/olimorris/neotest-rspec/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/olimorris/neotest-rspec/actions/workflows/ci.yml) -->

This plugin provides an [RSpec](https://rspec.info) adapter for the [Neotest](https://github.com/nvim-neotest/neotest) framework.

<img width="1502" alt="Neotest and RSpec" src="https://user-images.githubusercontent.com/9512444/174159395-d4dc5e1e-9c3c-449f-b235-6fc8835fed5b.png">

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
    })
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

> [!NOTE]
> You only need to the call the `setup` function if you wish to change any of the defaults

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
    filter_dirs = { ".git", "node_modules" },
    transform_spec_path = function(path)
      return path
    end,
    results_path = function()
      return async.fn.tempname()
    end
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

One issue you can run into is when you use generated tests:

```ruby
RSpec.describe SomeClass do
  describe "some feature" do
    FIXTURES.each do |method, path|
      it "does something with the #{method} and #{path}" do
        # ...
      end
    end
  end
end
```

The test will show as passing if any one of the tests pass instead of if all of
them pass. You can change the test command to use `--fail-fast` to fix this.
However now your other tests will all fail if even a single test fails.

To solve this you can customize your command depending on the type of test you
are running by using the optional positional argument `position_type`


```lua
require("neotest-rspec")({
  -- Optionally your function can take a position_type which is one of:
  -- - "file"
  -- - "test"
  -- - "dir"
  rspec_cmd = function(position_type)
    if position_type == "test" then
      return vim.tbl_flatten({
        "bundle",
        "exec",
        "rspec",
        "--fail-fast"
      })
    else
      return vim.tbl_flatten({
        "bundle",
        "exec",
        "rspec",
      })
    end
 end
})
```

Now when you run your tests from a single test it will fail fast and show the
correct error on your generated tests. When you run the whole file it won't fail
fast and a single error won't cause all your other tests to fail.

### Setting the root directory

For Neotest adapters to work, they need to define a project root whereby the process of discovering tests can take place. By default, the adapter looks for a `Gemfile`, `.rspec` or `.gitignore` file. These can be changed with:

```lua
require("neotest-rspec")({
  root_files = { "README.md" }
})
```

You can even set `root_files` with a function which returns a table:

```lua
require("neotest-rspec")({
  root_files = function() return { "README.md" } end
})
```

### Filtering directories

By default, the adapter will search for `_spec.rb` files in all dirs in the root with the exception of `node_modules` and `.git`. You can change this with:

```lua
require("neotest-rspec")({
  filter_dirs = { "my_custom_dir" }
})
```

You can even set `filter_dirs` with a function which returns a table:

```lua
require("neotest-rspec")({
  filter_dirs = function() return { "my_custom_dir" } end
})
```

### Running tests in a Docker container

The following configuration overrides `rspec_cmd` to run a Docker container (using `docker-compose`) and overrides `transform_spec_path` to pass the spec file as a relative path instead of an absolute path to RSpec. The `results_path` needs to be set to a location which is available to both the container and the host.

```lua
require("neotest").setup({
  adapters = {
    require("neotest-rspec")({
      rspec_cmd = function()
        return vim.tbl_flatten({
          "docker",
          "compose",
          "exec",
          "-i",
          "-w", "/app",
          "-e", "RAILS_ENV=test",
          "app",
          "bundle",
          "exec",
          "rspec"
        })
      end,

      transform_spec_path = function(path)
        local prefix = require('neotest-rspec').root(path)
        return string.sub(path, string.len(prefix) + 2, -1)
      end,

      results_path = "tmp/rspec.output"
    })
  }
})
```

Alternatively, you can accomplish this using a shell script as your RSpec command. See [this comment](https://github.com/nvim-neotest/neotest/issues/89#issuecomment-1338141432) for an example.

## :rocket: Usage

> [!IMPORTANT]
> In order for the adapter to work, your RSpec tests must end in `_spec.rb`

#### Test single function

To test a single test, hover over the test and run `require("neotest").run.run()`

#### Test file

To test a file run `require("neotest").run.run(vim.fn.expand("%"))`

#### Test directory

To test a directory run `require("neotest").run.run("path/to/directory")`

#### Test suite

To test the full test suite run `require("neotest").run.run("path/to/root_project")`
e.g. `require("neotest").run.run(vim.fn.getcwd())`, presuming that vim's directory is the same as the project root.

#### Debug test

In order to enable DAP for a test or test suite, ensure that [nvim-dap](https://github.com/mfussenegger/nvim-dap) and [nvim-dap-ruby](https://github.com/suketa/nvim-dap-ruby) are installed and follow the [strategies](https://github.com/nvim-neotest/neotest?tab=readme-ov-file#strategies) docs. An example snippet can be found below.

```lua
require("neotest").run.run({ strategy = "dap" })
```

This will run the closest test under DAP.

## :gift: Contributing

This project is maintained by the Neovim Ruby community. Please raise a PR if you are interested in adding new functionality or fixing any bugs. When submitting a bug, please include an example spec that can be tested.

To trigger the tests for the adapter, run:

```sh
make test
```
