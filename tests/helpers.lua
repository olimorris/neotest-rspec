local Helpers = {}

Helpers.child_start = function(child)
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua([[
    require("neotest").setup({
      adapters = { require("neotest-rspec") },
      consumers = { adapter_testing = require("neotest-rspec.consumers.adapter_testing") },
    })
  ]])
end

return Helpers
