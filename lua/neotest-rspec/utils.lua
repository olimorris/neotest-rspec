local ok, async = pcall(require, "nio")
if not ok then async = require("neotest.async") end

local logger = require("neotest.logging")

local M = {}
local separator = "::"

--- Replace paths in a string
---@param str string
---@param what string
---@param with string
---@return string
local function replace_paths(str, what, with)
  -- Taken from: https://stackoverflow.com/a/29379912/3250992
  what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
  with = string.gsub(with, "[%%]", "%%%%") -- escape replacement
  return string.gsub(str, what, with)
end

local function find_error_line(output)
  local backtrace = output.exception.backtrace
  -- Remove the leading dot from the file_path
  local file_path = string.sub(output.file_path, 2)
  local line_number

  for _, trace in ipairs(backtrace) do
    if string.find(trace, file_path) then
      line_number = tonumber(string.match(trace, ":(%d+):"))
      break
    end
  end

  return line_number
end

---@param position neotest.Position The position to return an ID for
---@param namespace neotest.Position[] Any namespaces the position is within
---@return string
M.generate_treesitter_id = function(position)
  local cwd = async.fn.getcwd()
  local test_path = "." .. replace_paths(position.path, cwd, "")
  -- Treesitter starts line numbers from 0 so we subtract 1
  local id = test_path .. separator .. (tonumber(position.range[1]) + 1)

  logger.debug("Cwd:", { cwd })
  logger.debug("Path to test file:", { position.path })
  logger.debug("Treesitter id:", { id })

  return id
end

---@param parsed_rspec_json table
---@param output_file string
---@return neotest.Result[]
M.parse_json_output = function(parsed_rspec_json, output_file, engine_name)
  local tests = {}

  for _, result in pairs(parsed_rspec_json.examples) do
    local test_id
    if engine_name then
      test_id = "./" .. engine_name .. string.sub(result.file_path, 2) .. separator .. result.line_number
    else
      test_id = result.file_path .. separator .. result.line_number
    end

    logger.debug("RSpec ID:", { test_id })

    if result.status == "pending" then result.status = "skipped" end

    tests[test_id] = {
      status = result.status,
      short = string.upper(result.file_path) .. "\n-> " .. string.upper(result.status) .. " - " .. result.description,
      testing_output = string.upper(result.file_path)
        .. "@@"
        .. string.upper(result.status)
        .. "@@"
        .. result.description,
      output_file = output_file,
    }

    if result.exception then
      tests[test_id].short = "Failures:\n\n"
        .. "  1) "
        .. result.full_description
        .. "\n   [31m  Failure/Error:\n"
        .. result.exception.message:gsub("\n", "\n\t")
        .. "[0m"

      tests[test_id].errors = {
        {
          line = (find_error_line(result) or result.line_number) - 1,
          message = result.exception.message:gsub("     ", ""):gsub("%\n+", "  "),
        },
      }
    end
  end

  return tests
end

return M
