local h = require("tests.helpers")

local eq = MiniTest.expect.equality
local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()
local T = new_set({
  hooks = {
    pre_case = function()
      h.child_start(child)
      child.lua([[vim.cmd(':e tests/stubs/blockless_it/blockless_it_spec.rb')]])
    end,
    post_case = function()
      child.lua([[TEST_OUTPUT = nil]])
    end,
    post_once = child.stop,
  },
})

T["blockless_it"] = new_set()

T["blockless_it"]["runs a single line test at line 6"] = function()
  child.lua([[
    vim.cmd(':6')
    require("neotest").run.run()
    vim.wait(10000, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/BLOCKLESS_IT/BLOCKLESS_IT_SPEC.RB@@PASSED@@is expected to eq 17" }, output)
end

T["blockless_it"]["runs a regular test at line 2"] = function()
  child.lua([[
    vim.cmd(':2')
    require("neotest").run.run()
    vim.wait(10000, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/BLOCKLESS_IT/BLOCKLESS_IT_SPEC.RB@@PASSED@@this works and gets tested by neotest" }, output)
end

T["blockless_it"]["runs a focused test at line 8"] = function()
  child.lua([[
    vim.cmd(':8')
    require("neotest").run.run()
    vim.wait(10000, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/BLOCKLESS_IT/BLOCKLESS_IT_SPEC.RB@@PASSED@@what about focus" }, output)
end

T["blockless_it"]["runs a single line test inside a context at line 13"] = function()
  child.lua([[
    vim.cmd(':13')
    require("neotest").run.run()
    vim.wait(10000, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/BLOCKLESS_IT/BLOCKLESS_IT_SPEC.RB@@PASSED@@is expected to eq 17" }, output)
end

T["blockless_it"]["runs a pending test at line 17"] = function()
  child.lua([[
    vim.cmd(':17')
    require("neotest").run.run()
    vim.wait(10000, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/BLOCKLESS_IT/BLOCKLESS_IT_SPEC.RB@@SKIPPED@@this is a pending test" }, output)
end

return T
