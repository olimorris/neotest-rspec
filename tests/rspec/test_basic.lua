local h = require("tests.helpers")

local eq = MiniTest.expect.equality
local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()
local T = new_set({
  hooks = {
    pre_once = function()
      h.child_start(child)
      child.lua([[vim.cmd(':e tests/stubs/basic/basic_spec.rb')]])
    end,
    pre_case = function()
      child.lua([[TEST_OUTPUT = nil]])
    end,
    post_once = child.stop,
  },
})

T["basic"] = new_set()

T["basic"]["runs a single test at line 2"] = function()
  child.lua([[
    vim.cmd(':2')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/BASIC/BASIC_SPEC.RB@@PASSED@@adds two numbers together" }, output)
end

T["basic"]["runs a single test at line 5"] = function()
  child.lua([[
    vim.cmd(':5')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/BASIC/BASIC_SPEC.RB@@PASSED@@subtracts two numbers together" }, output)
end

T["basic"]["runs all tests from the describe block"] = function()
  child.lua([[
    vim.cmd(':1')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({
    "./TESTS/STUBS/BASIC/BASIC_SPEC.RB@@PASSED@@adds two numbers together",
    "./TESTS/STUBS/BASIC/BASIC_SPEC.RB@@PASSED@@subtracts two numbers together",
  }, output)
end

return T
