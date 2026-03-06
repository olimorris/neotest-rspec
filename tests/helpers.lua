local Helpers = {}

-- Default timeout for waiting on neotest results in the child process.
-- CI environments need extra time for subprocess init + bundler cold start.
Helpers.timeout = 30000

Helpers.child_start = function(child)
  child.restart({ "-u", "scripts/child_init.lua" })
  child.lua([[
    require("neotest").setup({
      adapters = { require("neotest-rspec") },
      consumers = { adapter_testing = require("neotest-rspec.consumers.adapter_testing") },
    })
  ]])
end

return Helpers
