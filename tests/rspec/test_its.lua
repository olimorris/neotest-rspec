local h = require("tests.helpers")

local eq = MiniTest.expect.equality
local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()
local T = new_set({
  hooks = {
    pre_once = function()
      h.child_start(child)
      child.lua([[vim.cmd(':e tests/stubs/its/its_spec.rb')]])
    end,
    pre_case = function()
      child.lua([[TEST_OUTPUT = nil]])
    end,
    post_once = child.stop,
  },
})

T["its"] = new_set()

T["its"]["runs hash access with symbol key at line 8"] = function()
  child.lua([[
    vim.cmd(':8')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/ITS/ITS_SPEC.RB@@PASSED@@is expected to eq 1" }, output)
end

T["its"]["runs hash access with do block at line 11"] = function()
  child.lua([[
    vim.cmd(':11')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/ITS/ITS_SPEC.RB@@PASSED@@is expected to eq 2" }, output)
end

T["its"]["runs object access with symbol at line 18"] = function()
  child.lua([[
    vim.cmd(':18')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/ITS/ITS_SPEC.RB@@PASSED@@is expected to eq 4" }, output)
end

T["its"]["runs object access with do block at line 20"] = function()
  child.lua([[
    vim.cmd(':20')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/ITS/ITS_SPEC.RB@@PASSED@@is expected to eq 5" }, output)
end

T["its"]["runs object access with string at line 24"] = function()
  child.lua([[
    vim.cmd(':24')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/ITS/ITS_SPEC.RB@@PASSED@@is expected to eq 6" }, output)
end

return T
