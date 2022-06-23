local async = require("neotest.async")
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

---@param position neotest.Position The position to return an ID for
---@param namespace neotest.Position[] Any namespaces the position is within
---@return string
M.generate_treesitter_id = function(position)
  local cwd = async.fn.getcwd()
  local test_path = "." .. replace_paths(position.path, cwd, "")
  local id = test_path .. separator .. position.range[1]

  logger.info("Cwd:", { cwd })
  logger.info("Path to test file:", { position.path })
  logger.info("Treesitter id:", { id })

  return id
end

---@param parsed_rspec_json table
---@param output_file string
---@return neotest.Result[]
M.parse_json_output = function(parsed_rspec_json, output_file)
  local tests = {}

  for _, result in pairs(parsed_rspec_json.examples) do
    -- Treesitter starts line numbers from 0 so we subtract 1
    local test_id = result.file_path .. separator .. (result.line_number - 1)

    logger.info("RSpec ID:", { test_id })

    tests[test_id] = {
      status = result.status,
      short = string.upper(result.file_path) .. "\n-> " .. string.upper(result.status) .. " - " .. result.description,
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
          line = result.line_number,
          message = result.exception.message:gsub("     ", ""):gsub("%\n+", "  "),
        },
      }
    end
  end

  return tests
end

return M
