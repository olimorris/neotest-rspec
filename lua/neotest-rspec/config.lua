local M = {}

M.get_rspec_cmd = function()
  return vim.tbl_flatten({
    "bundle",
    "exec",
    "rspec",
  })
end

M.get_root_files = function()
  return {}
end

M.get_filter_dirs = function()
  return {}
end

return M
