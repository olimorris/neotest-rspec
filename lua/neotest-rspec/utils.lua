local logger = require("neotest.logging")

local M = {};

---@param position_id string
---@return string
M.form_treesitter_id = function(position_id)
  return position_id
    -- :gsub('<Namespace>.-</Namespace> ', '', 1) -- Remove the filename from the id
    :gsub("<Namespace>type:.-</Namespace> ", "") -- Remove any 'type: xx ' strings
    :gsub(' <Namespace>"#', "#") -- Weird edge case
    :gsub("<Test>should be_empty</Test>", "is expected to be empty") -- RSpec's one-liner syntax
    :gsub("<Test>is_expected.to be_empty</Test>", "is expected to be empty") -- RSpec's one-liner syntax
    :gsub("<Namespace>'", "")
    :gsub("'</Namespace>", "")
    :gsub('"</Namespace>', "")
    :gsub('<Namespace>"', "")
    :gsub("<Test>'", "")
    :gsub("'</Test>", "")
    :gsub('<Test>"', "")
    :gsub('"</Test>', "")
    :gsub("<Namespace>", "")
    :gsub("<Namespace>", "")
    :gsub("</Namespace>", "")
end

---@param parsed_rspec_json table
---@param output_file string
---@return neotest.Result[]
M.parse_json_output = function(parsed_rspec_json, output_file)
  local tests = {}

  for _, result in pairs(parsed_rspec_json.examples) do
    local test_id = result.full_description

    logger.info("RSpec ID:", { test_id })

    tests[test_id] = {
      status = result.status,
      short = string.upper(result.file_path) .. "\n-> " .. string.upper(result.status) .. " - " .. result.description,
      output_file = output_file,
    }

    if result.exception then
      tests[test_id].short = "Failures:\n\n"
        .. "  1) " .. result.full_description
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

return M;
