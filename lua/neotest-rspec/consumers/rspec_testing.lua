local cwd = vim.loop.cwd()

local neotest = {}
neotest.rspec_testing = {}

local function init(client)
  client.listeners.results = function(_, results)
    local output = {}
    for pos_id, result in pairs(results) do
      output[#output + 1] = result.testing_output
    end

    TEST_OUTPUT = output
  end
end

neotest.rspec_testing = setmetatable(neotest.rspec_testing, {
  __call = function(_, client)
    init(client)
    return neotest.rspec_testing
  end,
})

return neotest.rspec_testing
