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

return M;
