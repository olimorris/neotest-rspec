local async = require("plenary.async.tests")
local plugin = require("neotest-rspec")

describe("is_test_file", function()
  it("matches rspec files", function()
    assert.equals(true, plugin.is_test_file("./spec/foo_spec.rb"))
  end)

  it('does not match plain ruby files', function()
    assert.equals(false, plugin.is_test_file("./lib/foo.rb"))
  end)
end)

describe('discover_positions', function()
  async.it("provides meaningful names from a basic spec", function()
    local positions = plugin.discover_positions("./spec/nested/basic_spec.rb"):to_list()

    local expected_output  = {
      {
        name = "basic_spec.rb",
        type = "file",
      },
      {
        {
          name = "Nested::Foo",
          type = "namespace",
        },
        {
          {
            name = "'adds two numbers together'",
            type = "test",
          }
        }
      }
    }

    assert.equals(expected_output[1].name, positions[1].name)
    assert.equals(expected_output[1].type, positions[1].type)
    assert.equals(expected_output[2][1].name, positions[2][1].name)
    assert.equals(expected_output[2][1].type, positions[2][1].type)
    assert.equals(expected_output[2][2][1].name, positions[2][2][1].name)
    assert.equals(expected_output[2][2][1].type, positions[2][2][1].type)
  end)
end)
