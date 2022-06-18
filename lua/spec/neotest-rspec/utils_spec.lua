local utils = require("neotest-rspec.utils")

describe("form_treesitter_id", function()
  it("removes tags and quotes", function()
    assert.equals(
      "Array when first created",
      utils.form_treesitter_id(
        "<NS>Array</NS> <TS>'when first created'</TS>"
      )
    )
  end)
end)
