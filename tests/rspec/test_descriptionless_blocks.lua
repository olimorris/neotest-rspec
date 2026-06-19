local h = require("tests.helpers")

local eq = MiniTest.expect.equality
local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()
local T = new_set({
  hooks = {
    pre_once = function()
      h.child_start(child)
      child.lua([[vim.cmd(':e tests/stubs/descriptionless_blocks/descriptionless_blocks_spec.rb')]])
    end,
    pre_case = function()
      child.lua([[TEST_OUTPUT = nil]])
    end,
    post_once = child.stop,
  },
})

T["descriptionless_blocks"] = new_set()

T["descriptionless_blocks"]["runs a test inside a descriptionless block"] = function()
  child.lua([[
    vim.cmd(':2')
    require("neotest").run.run()
    vim.wait(]] .. h.timeout .. [[, function() return TEST_OUTPUT ~= nil end)
  ]])

  local output = child.lua_get([[TEST_OUTPUT]])
  eq({ "./TESTS/STUBS/DESCRIPTIONLESS_BLOCKS/DESCRIPTIONLESS_BLOCKS_SPEC.RB@@PASSED@@is expected to eq 17" }, output)
end

return T
