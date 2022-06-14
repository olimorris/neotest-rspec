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
NeotestAdapter.root = lib.files.match_root_pattern({ 'gemfile', '.rspec' })

---@async
---@param file_path string
---@return boolean
function NeotestAdapter.is_test_file(file_path)
  return vim.endswith(file_path, '_spec.rb') and true or false
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function NeotestAdapter.discover_positions(path)
  local query = [[
  ((call
      method: (identifier) @func_name (#match? @func_name "^(describe|context)$")
      arguments: (argument_list (_) @namespace.name)
  )) @namespace.definition

  ((call
    method: (identifier) @func_name (#eq? @func_name "it")
    arguments: (argument_list (_) @test.name)
  )) @test.definition
    ]]

  -- https://github.com/nvim-neotest/neotest/issues/9#issuecomment-1153155967
  local content = lib.files.read(path)
  local opts = {
    nested_tests = true,
    require_namespaces = true,
    ---@param position neotest.Position The position to return an ID for
    ---@param parents neotest.Position[] Parent positions for the position
    position_id = function(position, namespaces)
      return table.concat(
        vim.tbl_flatten({
          vim.tbl_map(function(pos)
            return '<NS>' .. pos.name .. '<NS>'
          end, namespaces),
          '<TS>' .. position.name .. '<TS>',
        }),
        ' '
      ):gsub(' <NS>"#', '#'):gsub("<NS>'", ''):gsub("'<NS>", ''):gsub('"<NS>', ''):gsub('<NS>"', ''):gsub(
        "<TS>'",
        ''
      ):gsub("'<TS>", ''):gsub('<TS>"', ''):gsub('"<TS>', ''):gsub('<NS>', '')
    end,
  }
  return lib.treesitter.parse_positions_from_string(path, content, query, opts)
end

---@param test_name string
---@return string
local function remove_quotations(test_name)
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
  local results_path = 'results.json'
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

  if position.type == 'file' then
    table.insert(script_args, position.path)
  end

  if position.type == 'test' or position.type == 'namespace' then
    table.insert(
      script_args,
      vim.tbl_flatten({
        '-e',
        remove_quotations(position.name),
      })
    )
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

---@param data string
---@param output_file string
---@return table
local function parse_json_output(data, output_file)
  local tests = {}

  for _, result in pairs(data.examples) do
    local test_file = result.file_path:gsub('./spec/', '')
    local test_id = test_file .. ' ' .. result.full_description

    tests[test_id] = {
      status = result.status == 'pending' and 'skipped' or result.status,
      short = string.upper(test_file:gsub('.rb', '')) .. '\n> ' .. result.description .. ': ' .. string.upper(
        result.status
      ),
      output = output_file,
      location = result.line_number,
    }
    if result.exception then
      tests[test_id].short = tests[test_id].short .. '\n' .. result.exception.message
      tests[test_id].errors = result.exception.backtrace
    end
  end

  return tests
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return neotest.Result[]
function NeotestAdapter.results(spec, result, tree)
  local output_file = spec.context.results_path

  local success, data = pcall(lib.files.read, output_file)
  if not success then
    logger.error('No test output file found ', output_file)
    return {}
  end

  local ok, parsed_data = pcall(vim.json.decode, data, { luanil = { object = true } })
  if not ok then
    logger.error('Failed to parse test output ', output_file)
    return {}
  end

  local ok, results = pcall(parse_json_output, parsed_data, output_file)
  if not ok then
    logger.error('Failed to get test results ', output_file)
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
