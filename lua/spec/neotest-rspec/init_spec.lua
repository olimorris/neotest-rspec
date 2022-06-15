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
  it('matches rspec files', function()
    assert.equals('something', plugin.discover_positions('./spec/nested_tests/nested_spec.rb'))
  end)
end)
