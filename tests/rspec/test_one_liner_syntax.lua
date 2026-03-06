local h = require("tests.helpers")

local eq = MiniTest.expect.equality
local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()
local T = new_set({
  hooks = {
    pre_once = function()
      h.child_start(child)
      child.lua([[vim.cmd(':e tests/stubs/one_liner_syntax/one_liner_syntax_spec.rb')]])
    end,
    pre_case = function()
      child.lua([[TEST_OUTPUT = nil]])
    end,
    post_once = child.stop,
  },
})

T["one_liner_syntax"] = new_set()

T["one_liner_syntax"]["runs should syntax at line 3"] = function()
  child.lua([[
    vim.cmd(':3')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/ONE_LINER_SYNTAX/ONE_LINER_SYNTAX_SPEC.RB@@PASSED@@is expected to be empty" }, output)
end

T["one_liner_syntax"]["runs is_expected syntax at line 6"] = function()
  child.lua([[
    vim.cmd(':6')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/ONE_LINER_SYNTAX/ONE_LINER_SYNTAX_SPEC.RB@@PASSED@@is expected to be empty" }, output)
end

T["one_liner_syntax"]["runs multi-line do block at line 10"] = function()
  child.lua([[
    vim.cmd(':10')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/ONE_LINER_SYNTAX/ONE_LINER_SYNTAX_SPEC.RB@@PASSED@@is expected to be empty" }, output)
end

T["one_liner_syntax"]["runs expect syntax in do block at line 13"] = function()
  child.lua([[
    vim.cmd(':13')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/ONE_LINER_SYNTAX/ONE_LINER_SYNTAX_SPEC.RB@@PASSED@@is expected to equal true" }, output)
end

return T
