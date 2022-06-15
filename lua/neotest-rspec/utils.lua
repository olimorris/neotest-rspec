local M = {};

---@param position_id string
---@return string
M.form_treesitter_id = function(position_id)
  return position_id
    -- :gsub('<NS>.-</NS> ', '', 1) -- Remove the filename from the id
    :gsub('<NS>type:.-</NS> ', '') -- Remove any 'type: xx ' strings
    :gsub(' <NS>"#', '#') -- Weird edge case
    :gsub('<TS>should be_empty</TS>', 'is expected to be empty') -- RSpec's one-liner syntax
    :gsub('<TS>is_expected.to be_empty</TS>', 'is expected to be empty') -- RSpec's one-liner syntax
    :gsub("<NS>'", '')
    :gsub("'</NS>", '')
    :gsub('"</NS>', '')
    :gsub('<NS>"', '')
    :gsub("<TS>'", '')
    :gsub("'</TS>", '')
    :gsub('<TS>"', '')
    :gsub('"</TS>', '')
    :gsub('<NS>', '')
    :gsub('<NS>', '')
    :gsub('</NS>', '')
end

return M;
