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

M.engine_support = true

M.results_path = function()
  return require("neotest.async").fn.tempname()
end

M.formatter = function()
  return "NeotestFormatter"
end

return M
