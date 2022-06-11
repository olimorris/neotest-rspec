local async = require('neotest.async')
local lib = require('neotest.lib')
local logger = require('neotest.logging')

---@class neotest.Adapter
---@field name string
local NeotestAdapter = { name = 'neotest-rspec' }

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
NeotestAdapter.root = lib.files.match_root_pattern({ 'Gemfile', '.rspec' })

---@async
---@param file_path string
---@return boolean
function NeotestAdapter.is_test_file(file_path)
  if not vim.endswith(file_path, '_spec.rb') then
    return false
  end
  return true
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function NeotestAdapter.discover_positions(path)
  local query = [[
  ((call
      method: (identifier) @func_name (#match? @func_name "^describe")
      arguments: (argument_list (_) @namespace.name)
  )) @namespace.definition


  ((call
    method: (identifier) @func_name (#match? @func_name "^it")
    arguments: (argument_list (_) @test.name)
  )) @test.definition
    ]]
  return lib.treesitter.parse_positions(path, query, { nested_tests = true })
end

---@param args neotest.RunArgs
---@return neotest.RunSpec | nil
function NeotestAdapter.build_spec(args)
  local position = args.tree:data()
  local results_path = async.fn.tempname()
  local root = NeotestAdapter.root(position.path)

  local runner = vim.tbl_flatten({
    'bundle',
    'exec',
    'rspec',
  })
  local script_args = vim.tbl_flatten({
    '-f',
    'json',
    '-o',
    results_path,
  })
  if position then
    table.insert(script_args, position.id)
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

local function cleanAnsi(s)
  return s
    :gsub('\x1b%[%d+;%d+;%d+;%d+;%d+m', '')
    :gsub('\x1b%[%d+;%d+;%d+;%d+m', '')
    :gsub('\x1b%[%d+;%d+;%d+m', '')
    :gsub('\x1b%[%d+;%d+m', '')
    :gsub('\x1b%[%d+m', '')
end

local function parsed_json_to_results(data, output_file)
  local tests = {}
  local failed = false

  for _, result in pairs(data.examples) do
    local status, name = result.status, result.description
    if name == nil then
      logger.error('Failed to find parsed test result ', result)
      return {}, failed
    end

    local keyid = result.file_path .. "::" .. result.line_number
    tests[keyid] = {
      status = status == 'pending' and 'skipped' or status,
      short = name .. ': ' .. status,
      output = output_file,
      location = result.file_path,
    }

    if result.status == 'failed' then
      failed = true
      local errors = {}
      local failure_msg = result.exception.message
      tests[keyid].short = tests[keyid].short .. '\n' .. failure_msg
      tests[keyid].errors = {
        line = result.line_number,
        msg = failure_msg,
      }
    end
  end
  return tests, failed
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return neotest.Result[]
function NeotestAdapter.results(spec, _, tree)
  local output_file = spec.context.results_path

  local success, data = pcall(lib.files.read, output_file)
  if not success then
    logger.error('No test output file found ', output_file)
    return {}
  end

  local ok, parsed = pcall(vim.json.decode, data, { luanil = { object = true } })
  if not ok then
    logger.error('Failed to parse test output json ', output_file)
    return {}
  end

  local results, failed = parsed_json_to_results(parsed, output_file)
  om.print_table(results)
  for _, value in tree:iter() do
    if value.type ~= 'file' or value.type ~= 'namespace' then
      logger.error('Failed to find test result ', value)
      return results
    end
    results[value.id] = {
      status = 'passed',
      output = output_file,
    }
    if failed then
      results[value.id].status = 'failed'
    end
  end
  return results
end

setmetatable(NeotestAdapter, {
  __call = function()
    return NeotestAdapter
  end,
})

return NeotestAdapter
