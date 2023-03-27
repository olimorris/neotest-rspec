local plugin = require("neotest-rspec")

describe("is_test_file", function()
  it("matches rspec files", function()
    assert.equals(true, plugin.is_test_file("./spec/foo_spec.rb"))
  end)

  it("does not match plain ruby files", function()
    assert.equals(false, plugin.is_test_file("./lib/foo.rb"))
  end)
end)

describe("filter_dir", function()
  -- note that even though these tests suggest that `engine/things/spec` would be approved,
  -- `engine/things` would return false, so `engine/things/spec` would never be searched by
  -- neotest
  local root = "/home/name/projects"
  it("allows spec", function()
    assert.equals(true, plugin.filter_dir("spec", "spec", root))
  end)
  it("allows sub directories one deep (for engines)", function()
    assert.equals(true, plugin.filter_dir("test_engine", "test_engine", root))
  end)
  it("allows paths that contain spec", function()
    assert.equals(true, plugin.filter_dir("spec", "test_engine/spec", root))
  end)
  it("allows a long path with spec at the start", function()
    assert.equals(true, plugin.filter_dir("billing_service", "spec/controllers/billing_service", root))
  end)
  it("disallows paths without spec, more that one sub dir deep", function()
    assert.equals(false, plugin.filter_dir("models", "app/models", root))
  end)
end)
