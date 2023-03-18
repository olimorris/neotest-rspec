local cwd = vim.loop.cwd()

local neotest = {}

---@text
-- A consumer that outputs the results to the clipboard
neotest.rspec_testing = {}

---@private
---@type neotest.Client
local client

local init = function()
  client.listeners.results = function(adapter_id, results, partial)
    local tree = assert(client:get_position(nil, { adapter = adapter_id }))
    local short_output = {}
    for pos_id, result in pairs(results) do
      short_output[#short_output + 1] = result.short
    end

    -- Write the output to disk
    local file = io.open(cwd .. "/tests/test_output.txt", "a+")
    for _, output in pairs(short_output) do
      if file then
        file:write(output)
      end
    end
    if file then
      file:close()
    end
  end
end

neotest.rspec_testing = setmetatable(neotest.rspec_testing, {
  __call = function(_, client_)
    client = client_
    init()
    return neotest.rspec_testing
  end,
})

return neotest.rspec_testing
