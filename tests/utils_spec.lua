local utils = require("neotest-rspec.utils")

describe("generate_treesitter_id", function()
  it("forms an id", function()
    local ts = {
      name = "'adds two numbers together'",
      path = vim.loop.cwd() .. "/spec/basic_spec.rb",
      range = {
        1,
        2,
        3,
        5,
      },
      type = "test",
    }

    assert.equals("./spec/basic_spec.rb::2", utils.generate_treesitter_id(ts))
  end)
end)

describe("parse_json_output", function()
  it("extracts summary info from a passed rspec example", function()
    local parsed_rspec_json = {
      examples = {
        {
          id = "/spec/basic_spec.rb[1:1]",
          description = "adds two numbers together",
          full_description = "Maths adds two numbers together",
          status = "passed",
          file_path = "./spec/basic_spec.rb",
          line_number = 2,
          run_time = 0.000192247,
        },
      },
    }

    local expected_output = {
      ["./spec/basic_spec.rb::2"] = {
        output_file = "/tmp/nvimhYaIPj/3",
        short = "./SPEC/BASIC_SPEC.RB\n-> PASSED - adds two numbers together",
        status = "passed",
      },
    }

    assert.are.same(expected_output, utils.parse_json_output(parsed_rspec_json, "/tmp/nvimhYaIPj/3"))
  end)

  it("works with engine specs", function()
    local parsed_rspec_json = {
      examples = {
        {
          id = "./spec/basic_spec.rb[1:1]",
          description = "adds two numbers together",
          full_description = "Maths adds two numbers together",
          status = "passed",
          file_path = "./spec/basic_spec.rb",
          line_number = 2,
          run_time = 0.000192247,
        },
      },
    }

    local expected_output = {
      ["./engine_name/spec/basic_spec.rb::2"] = {
        output_file = "/tmp/nvimhYaIPj/3",
        short = "./SPEC/BASIC_SPEC.RB\n-> PASSED - adds two numbers together",
        status = "passed",
      },
    }

    assert.are.same(expected_output, utils.parse_json_output(parsed_rspec_json, "/tmp/nvimhYaIPj/3", "engine_name"))
  end)
end)
