--Ref: ThePrimeagen/Refactoring.nvim - Uses an awesome approach to testing functions
--https://github.com/ThePrimeagen/refactoring.nvim/blob/57c32c6b7a211e5a3a5e4ddc4ad2033daff5cf9a/lua/refactoring/utils.lua#L34

local Path = require("plenary.path")

local M = {}

function M.split_string(inputstr, sep)
  local t = {}
  -- [[ lets not think about the edge case there... --]]
  while #inputstr > 0 do
    local start, stop = inputstr:find(sep)
    local str
    if not start then
      str = inputstr
      inputstr = ""
    else
      str = inputstr:sub(1, start - 1)
      inputstr = inputstr:sub(stop + 1)
    end
    table.insert(t, str)
  end
  return t
end

function M.read_file(file)
    return Path:new("", file):read()
end

function M.get_contents(file)
    return M.split_string(M.read_file(file), "\n")
end

local function get_commands(filename_prefix)
  return M.split_string(M.read_file(string.format("%s.commands", filename_prefix)), "\n")
end

function M.run_commands(filename_prefix)
  for _, command in pairs(get_commands(filename_prefix)) do
    vim.cmd(command)
  end
end

function M.open_test_file(file)
  vim.cmd(":e " .. file)
  return vim.api.nvim_get_current_buf()
end

function M.check_if_skip_test(test_name, tests_to_skip)
  for _, test in pairs(tests_to_skip) do
    if test_name == test then
      return true
    end
  end
  return false
end

return M
