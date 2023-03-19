local function is_treesitter_installed()
  local ok, _ = pcall(require, "nvim-treesitter.configs")
  return ok
end

describe("Treesitter check", function()
  it("should check if Treesitter is installed and working", function()
    local treesitter_installed = is_treesitter_installed()
    assert.are.same(true, treesitter_installed)
  end)
end)
