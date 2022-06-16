local async = require("plenary.async.tests")

local plugin = require('neotest-rspec')

describe('is_test_file', function()
  it('matches rspec files', function()
    assert.equals(true, plugin.is_test_file('./spec/foo_spec.rb'))
  end)

  it('does not match plain ruby files', function()
    assert.equals(false, plugin.is_test_file('./lib/foo.rb'))
  end)
end)

describe('discover_positions', function()
  async.it('creates a meaningful tree of ids', function()
    local positions = plugin.discover_positions('./spec/nested/basic_spec.rb')

    assert.equals('basic_spec.rb', positions._data.name)
    assert.equals('Maths', positions._nodes.Maths._data.id)
  end)
end)