local logger = require("neotest.logging")

local M = {}

---@param position neotest.Position The position to return an ID for
---@param namespaces neotest.Position[] Any namespaces the position is within
---@return string
M.generate_treesitter_id = function(position, namespace)
  local id = table.concat(vim.tbl_flatten({ position.path, position.range[1] }), "::")
  logger.info("Treesitter id:", id)
  return id
end

---@param parsed_rspec_json table
---@param output_file string
---@return neotest.Result[]
M.parse_json_output = function(parsed_rspec_json, output_file)
  local tests = {}

  for _, result in pairs(parsed_rspec_json.tests) do
    local test_id = result.treesitter_id

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
