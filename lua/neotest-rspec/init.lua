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

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project
---@return boolean
function NeotestAdapter.filter_dir(name, rel_path, root)
  local _, count = rel_path:gsub("/", "")
  if rel_path:match("spec") or count < 1 then
    return true
  end
  return false
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function NeotestAdapter.discover_positions(path)
  local query = [[
    ((call
      method: (identifier) @func_name (#match? @func_name "^(describe|context|feature)$")
      arguments: (argument_list (_) @namespace.name)
    )) @namespace.definition

    ((call
      method: (identifier) @namespace.name (#match? @namespace.name "^(describe|context|feature)$")
      .
      block: (_)
    )) @namespace.definition

    ((call
      method: (identifier) @func_name (#match? @func_name "^(it|scenario|it_behaves_like)$")
      arguments: (argument_list (_) @test.name)
    )) @test.definition

    ((call
      method: (identifier) @func_name (#eq? @func_name "it")
      block: (block (_) @test.name)
    )) @test.definition

    ((call
      method: (identifier) @func_name (#eq? @func_name "it")
      block: (do_block (_) @test.name)
    )) @test.definition
  ]]

  return lib.treesitter.parse_positions(path, query, {
    nested_tests = true,
    require_namespaces = true,
    position_id = "require('neotest-rspec.utils').generate_treesitter_id",
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

---@return string
local function get_rspec_cmd()
  return vim.tbl_flatten({
    "bundle",
    "exec",
    "rspec",
  })
end

---@param args neotest.RunArgs
---@return neotest.RunSpec | nil
function NeotestAdapter.build_spec(args)
  local position = args.tree:data()
  local engine_name = nil

  local path = async.fn.expand("%")

  -- if the path starts with spec, it's a normal test. Otherwise, it's an engine test
  local match = vim.regex("spec/"):match_str(path)
  if match and match ~= 0 then
    engine_name = string.sub(path, 0, match - 1)
  end
  local results_path = async.fn.tempname()

  local script_args = vim.tbl_flatten({
    "-f",
    "json",
    "-o",
    results_path,
    "-f",
    "progress",
  })

  local function run_by_filename()
    table.insert(script_args, position.path)
  end

  local function run_by_line_number()
    table.insert(
      script_args,
      vim.tbl_flatten({
        position.path .. ":" .. tonumber(position.range[1] + 1),
      })
    )
  end

  if position.type == "file" then
    run_by_filename()
  end

  if position.type == "test" or (position.type == "namespace" and vim.bo.filetype ~= "neotest-summary") then
    run_by_line_number()
  end

  if position.type == "dir" and vim.bo.filetype == "neotest-summary" then
    run_by_filename()
  end

  local command = vim.tbl_flatten({
    get_rspec_cmd(),
    script_args,
  })

  return {
    cwd = engine_name,
    command = command,
    context = {
      results_path = results_path,
      engine_name = engine_name,
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
  local engine_name = spec.context.engine_name

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

  local ok, results = pcall(utils.parse_json_output, parsed_data, output_file, engine_name)
  if not ok then
    logger.error("Failed to get test results:", output_file)
    return {}
  end

  return results
end

local is_callable = function(obj)
  return type(obj) == "function" or (type(obj) == "table" and obj.__call)
end

setmetatable(NeotestAdapter, {
  __call = function(_, opts)
    if is_callable(opts.rspec_cmd) then
      get_rspec_cmd = opts.rspec_cmd
    elseif opts.rspec_cmd then
      get_rspec_cmd = function()
        return opts.rspec_cmd
      end
    end
    return NeotestAdapter
  end,
})

return NeotestAdapter
