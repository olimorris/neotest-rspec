local function is_treesitter_installed()
  local ok, _ = pcall(require, "nvim-treesitter.configs")
  return ok
end

local function is_ruby_parser_installed()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then return false end

  local has_ruby = parsers.has_parser("ruby")
  return has_ruby
end

describe("Treesitter check", function()
  it("should check if Treesitter is installed and working", function()
    local treesitter_installed = is_treesitter_installed()
    assert.are.same(true, treesitter_installed)
  end)

  it("should check if the Ruby parser is installed and working", function()
    local ruby_parser_installed = is_ruby_parser_installed()
    assert.are.same(true, ruby_parser_installed)
  end)
end)
