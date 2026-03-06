local eq = MiniTest.expect.equality
local new_set = MiniTest.new_set

local T = new_set()

T["treesitter"] = new_set()

T["treesitter"]["should be installed and working"] = function()
  local ok, _ = pcall(require, "nvim-treesitter")
  eq(true, ok)
end

T["treesitter"]["should have the Ruby parser installed"] = function()
  local ok = pcall(vim.treesitter.language.inspect, "ruby")
  eq(true, ok)
end

return T
