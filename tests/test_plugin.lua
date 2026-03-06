local plugin = require("neotest-rspec")

local eq = MiniTest.expect.equality
local new_set = MiniTest.new_set

local T = new_set()

T["is_test_file"] = new_set()

T["is_test_file"]["matches rspec files"] = function()
  eq(true, plugin.is_test_file("./spec/foo_spec.rb"))
end

T["is_test_file"]["does not match plain ruby files"] = function()
  eq(false, plugin.is_test_file("./lib/foo.rb"))
end

T["filter_dir"] = new_set()

T["filter_dir"]["allows spec"] = function()
  eq(true, plugin.filter_dir("spec", "spec", "/home/name/projects"))
end

T["filter_dir"]["allows sub directories one deep (for engines)"] = function()
  eq(true, plugin.filter_dir("test_engine", "test_engine", "/home/name/projects"))
end

T["filter_dir"]["allows paths that contain spec"] = function()
  eq(true, plugin.filter_dir("spec", "test_engine/spec", "/home/name/projects"))
end

T["filter_dir"]["allows a long path with spec at the start"] = function()
  eq(true, plugin.filter_dir("billing_service", "spec/controllers/billing_service", "/home/name/projects"))
end

T["filter_dir"]["denies paths that contain tmp"] = function()
  eq(false, plugin.filter_dir("tmp"))
end

return T
