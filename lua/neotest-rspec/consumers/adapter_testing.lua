local cwd = vim.loop.cwd()

local neotest = {}
neotest.adapter_testing = {}

local function init(client)
  client.listeners.results = function(_, results)
    local output = {}

    -- Capture the custom testing_output string
    for _, result in pairs(results) do
      output[#output + 1] = result.testing_output
    end

    -- Sort alphabetically
    table.sort(output, function(a, b)
      return a < b
    end)

    TEST_OUTPUT = output
  end
end

neotest.adapter_testing = setmetatable(neotest.adapter_testing, {
  __call = function(_, client)
    init(client)
    return neotest.adapter_testing
  end,
})

return neotest.adapter_testing
