local h = require("tests.helpers")

local eq = MiniTest.expect.equality
local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()
local T = new_set({
  hooks = {
    pre_once = function()
      h.child_start(child)
      child.lua([[vim.cmd(':e engine/spec/engine_spec.rb')]])
    end,
    pre_case = function()
      child.lua([[TEST_OUTPUT = nil]])
    end,
    post_once = child.stop,
  },
})

T["engine"] = new_set()

T["engine"]["runs specs from the engine root"] = function()
  child.lua([[
    vim.cmd(':1')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./SPEC/ENGINE_SPEC.RB@@PASSED@@runs specs from the engine root" }, output)
end

T["engine"]["fails when engine support is disabled"] = function()
  child.lua([[
    vim.cmd(':lua require("neotest-rspec")({engine_support=false})')
    vim.cmd(':1')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./ENGINE/SPEC/ENGINE_SPEC.RB@@FAILED@@runs specs from the engine root" }, output)
end

return T
