local utils = require("neotest-rspec.utils")

describe("form_treesitter_id", function()
  it("removes tags and quotes", function()
    assert.equals(
      "Array when first created",
      utils.form_treesitter_id(
        "<Namespace>Array</Namespace> <Test>'when first created'</Test>"
      )
    )
  end)
end)

describe("parse_json_output", function()
  it("extracts summary info from a passed rspec example", function()
    local parsed_rspec_json = {
      examples = {{
        id = "/spec/basic_spec.rb[1:1]",
        description = "adds two numbers together",
        full_description = "Maths adds two numbers together",
        status = "passed",
        file_path = "./spec/basic_spec.rb",
        line_number = 2,
        run_time = 0.000192247
      }}
    }

    local expected_output = {
      ["Maths adds two numbers together"] = {
        output_file = "/tmp/nvimhYaIPj/3",
        short = "./SPEC/BASIC_SPEC.RB\n-> PASSED - adds two numbers together",
        status = "passed"
      }
    }

    assert.are.same(
      expected_output,
      utils.parse_json_output(parsed_rspec_json, "/tmp/nvimhYaIPj/3")
    )
  end)
end)
