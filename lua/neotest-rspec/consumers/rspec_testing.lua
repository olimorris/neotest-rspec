local cwd = vim.loop.cwd()

local neotest = {}
neotest.rspec_testing = {}

local function init(client)
  client.listeners.results = function(_, results)
    local short_output = {}
    for pos_id, result in pairs(results) do
      short_output[#short_output + 1] = result.short
    end

    -- Write the output to disk
    local file = io.open(cwd .. "/test_output.txt", "w+")
    for _, output in pairs(short_output) do
      if file then
        file:write(output .. "\n")
      else
        print("Could not write to file")
      end
    end
    if file then
      file:close()
    end
  end
end

neotest.rspec_testing = setmetatable(neotest.rspec_testing, {
  __call = function(_, client)
    init(client)
    return neotest.rspec_testing
  end,
})

return neotest.rspec_testing
