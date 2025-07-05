local M = {}

M.get_rspec_cmd = function()
  return vim.tbl_flatten({
    "bundle",
    "exec",
    "rspec",
  })
end

M.get_root_files = function()
  return { "Gemfile", ".rspec", ".gitignore" }
end

M.get_filter_dirs = function()
  return { ".git", "node_modules", "tmp" }
end

M.transform_spec_path = function(path)
  return path
end

M.results_path = function()
  return require("neotest.async").fn.tempname()
end

M.formatter = function()
  return "NeotestFormatter"
end

M.formatter_path = function()
  -- Get the directory of the current init.lua file
  local plugin_root =
    vim.fn.fnamemodify(vim.api.nvim_get_runtime_file("lua/neotest-rspec/init.lua", false)[1], ":h:h:h")

  -- Construct the path to formatter.rb
  local formatter_path = plugin_root .. "/neotest_formatter.rb"

  -- Return the absolute path
  return vim.fn.resolve(formatter_path)
end

return M
