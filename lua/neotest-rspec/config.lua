local M = {}

M.get_strategy_config = function(strategy, command, cwd)
  local strategy_config = {
    dap = function()
      return {
        name = "Debug RSpec Tests",
        type = "ruby",
        args = { unpack(command, 2) },
        command = command[1],
        cwd = cwd or "${workspaceFolder}",
        current_line = true,
        random_port = true,
        request = "attach",
        error_on_failure = false,
        localfs = true,
      }
    end,
  }
  if strategy_config[strategy] then return strategy_config[strategy]() end
end

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

return M
