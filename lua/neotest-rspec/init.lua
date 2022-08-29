local async = require("neotest.async")
local lib = require("neotest.lib")
local logger = require("neotest.logging")
local utils = require("neotest-rspec.utils")

---@class neotest.Adapter
---@field name string
local NeotestAdapter = { name = "neotest-rspec" }

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
NeotestAdapter.root = lib.files.match_root_pattern("Gemfile", ".rspec", ".gitignore")

---@async
---@param file_path string
---@return boolean
function NeotestAdapter.is_test_file(file_path)
  return vim.endswith(file_path, "_spec.rb")
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function NeotestAdapter.discover_positions(path)
  local query = [[
    (program (call
      method: (identifier) @func_name (#match? @func_name "^(describe|context|feature)$")
      arguments: (argument_list (_) @namespace.name)
    )) @namespace.definition

    ((call
      method: (identifier) @func_name (#match? @func_name "^(it|scenario)$")
      arguments: (argument_list (_) @test.name)
    )) @test.definition

    ((call
      method: (identifier) @func_name (#eq? @func_name "it")
      block: (block (_) @test.name)
    )) @test.definition
  ]]

  return lib.treesitter.parse_positions(path, query, {
    nested_tests = true,
    require_namespaces = true,
    position_id = utils.generate_treesitter_id,
  })
end

---@param test_name string
---@return string
local function clean_test_name(test_name)
  if string.sub(test_name, -1) == '"' or string.sub(test_name, -1) == "'" then
    test_name = test_name:sub(1, -2)
  end
  if string.sub(test_name, 1, 1) == '"' or string.sub(test_name, 1, 1) == "'" then
    test_name = test_name:sub(2, #test_name)
  end
  return test_name
end

---@param args neotest.RunArgs
---@return neotest.RunSpec | nil
function NeotestAdapter.build_spec(args)
  local position = args.tree:data()
  local results_path = async.fn.tempname()

  local runner = vim.tbl_flatten({
    "bundle",
    "exec",
    "rspec",
  })
  local script_args = vim.tbl_flatten({
    "-f",
    "json",
    "-o",
    results_path,
    "-f",
    "progress",
  })

  if position.type == "file" then
    table.insert(script_args, position.path)
  end

  local function run_by_test_name()
    table.insert(
      script_args,
      vim.tbl_flatten({
        "-e",
        clean_test_name(position.name),
      })
    )
  end

  local function run_by_line_number()
    table.insert(
      script_args,
      vim.tbl_flatten({
        position.path .. ":" .. tonumber(position.range[1] + 1),
      })
    )
  end

  if position.type == "namespace" then
    run_by_test_name()
  end

  if position.type == "test" then
    run_by_line_number()
  end

  local command = vim.tbl_flatten({
    runner,
    script_args,
  })

  return {
    command = command,
    context = {
      results_path = results_path,
    },
  }
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return neotest.Result[]
function NeotestAdapter.results(spec, result, tree)
  local output_file = spec.context.results_path

  local ok, data = pcall(lib.files.read, output_file)
  if not ok then
    logger.error("No test output file found:", output_file)
    return {}
  end

  local ok, parsed_data = pcall(vim.json.decode, data, { luanil = { object = true } })
  if not ok then
    logger.error("Failed to parse test output:", output_file)
    return {}
  end

  local ok, results = pcall(utils.parse_json_output, parsed_data, output_file)
  if not ok then
    logger.error("Failed to get test results:", output_file)
    return {}
  end

  return results
end

setmetatable(NeotestAdapter, {
  __call = function()
    return NeotestAdapter
  end,
})

return NeotestAdapter
