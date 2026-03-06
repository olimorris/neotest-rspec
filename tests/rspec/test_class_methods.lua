local h = require("tests.helpers")

local eq = MiniTest.expect.equality
local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()
local T = new_set({
  hooks = {
    pre_case = function()
      h.child_start(child)
      child.lua([[vim.cmd(':e tests/stubs/class_methods/class_methods_spec.rb')]])
    end,
    post_case = function()
      child.lua([[TEST_OUTPUT = nil]])
    end,
    post_once = child.stop,
  },
})

T["class_methods"] = new_set()

T["class_methods"]["runs all tests in the .new describe block"] = function()
  child.lua([[
    vim.cmd(':5')
    require("neotest").run.run()
    vim.wait(10000, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq(2, #output)
  eq(true, output[1]:find("PASSED") ~= nil)
  eq(true, output[1]:find("method naming convention") ~= nil)
  eq(true, output[2]:find("SKIPPED") ~= nil)
  eq(true, output[2]:find("skipped handles the") ~= nil)
end

T["class_methods"]["runs a single test at line 9"] = function()
  child.lua([[
    vim.cmd(':9')
    require("neotest").run.run()
    vim.wait(10000, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq(1, #output)
  eq(true, output[1]:find("PASSED") ~= nil)
  eq(true, output[1]:find("method naming convention") ~= nil)
end

return T
