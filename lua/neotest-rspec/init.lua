local lib = require("neotest.lib")
local async = require("neotest.async")
local logger = require("neotest.logging")
local utils = require("neotest-rspec.utils")
local config = require("neotest-rspec.config")

---@class neotest.Adapter
---@field name string
local NeotestAdapter = { name = "neotest-rspec" }

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function NeotestAdapter.root(dir)
  local result = nil

  for _, root_file in ipairs(config.get_root_files()) do
    result = lib.files.match_root_pattern(root_file)(dir)
    if result then break end
  end

  return result
end

---@async
---@param file_path string
---@return boolean
function NeotestAdapter.is_test_file(file_path)
  return vim.endswith(file_path, "_spec.rb")
end

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@return boolean
function NeotestAdapter.filter_dir(name)
  for _, filter_dir in ipairs(config.get_filter_dirs()) do
    if name == filter_dir then return false end
  end

  return true
end

---Given a file path, parse all the tests within it.
---@async
---@param path string Absolute file path
---@return neotest.Tree | nil
function NeotestAdapter.discover_positions(path)
  local query = [[
    ((call
      method: (identifier) @func_name (#match? @func_name "^(describe|shared_examples|context|feature)$")
      arguments: (argument_list (_) @namespace.name)
    )) @namespace.definition

    ((call
      method: (identifier) @namespace.name (#match? @namespace.name "^(describe|shared_examples|context|feature)$")
      .
      block: (_)
    )) @namespace.definition

    ((call
      method: (identifier) @func_name (#match? @func_name "^(it|its|specify)$")
      block: (block (_) @test.name)
    )) @test.definition

    ((call
      method: (identifier) @func_name (#match? @func_name "^(it|its|specify)$")
      block: (do_block (_) @test.name)
      !arguments
    )) @test.definition

    ((call
      method: (identifier) @func_name (#match? @func_name "^(it|its|scenario|include_examples|it_behaves_like)$")
      arguments: (argument_list (_) @test.name)
    )) @test.definition
  ]]

  return lib.treesitter.parse_positions(path, query, {
    nested_tests = true,
    require_namespaces = true,
    position_id = "require('neotest-rspec.utils').generate_treesitter_id",
  })
end

local function get_formatter_path()
  -- Get the directory of the current init.lua file
  local plugin_root =
    vim.fn.fnamemodify(vim.api.nvim_get_runtime_file("lua/neotest-rspec/init.lua", false)[1], ":h:h:h")

  -- Construct the path to formatter.rb
  local formatter_path = plugin_root .. "/neotest_formatter.rb"

  -- Return the absolute path
  return vim.fn.resolve(formatter_path)
end

---@param args neotest.RunArgs
---@return neotest.RunSpec | nil
function NeotestAdapter.build_spec(args)
  local position = args.tree:data()
  local engine_name = nil

  local spec_path = config.transform_spec_path(position.path)
  local path = async.fn.expand("%")

  -- if the path starts with spec, it's a normal test. Otherwise, it's an engine test
  local match = vim.regex("^spec/"):match_str(path)
  if match and match ~= 0 then engine_name = string.sub(path, 0, match - 1) end
  local results_path = config.results_path()

  local formatter_path = get_formatter_path()
  local formatter = config.formatter()

  local script_args = {
    "-f",
    formatter,
    "-o",
    results_path,
    "-f",
    "progress",
  }

  if formatter == "NeotestFormatter" then
    script_args = vim.tbl_flatten({
      "--require",
      formatter_path,
      script_args,
    })
  end

  local function run_by_filename()
    table.insert(script_args, spec_path)
  end

  local function run_by_line_number()
    table.insert(
      script_args,
      vim.tbl_flatten({
        spec_path .. ":" .. tonumber(position.range[1] + 1),
      })
    )
  end

  local function get_strategy_config(strategy, command, cwd)
    local strategy_config = {
      dap = function()
        return {
          name = "Debug RSpec Tests",
          type = "ruby",
          args = { unpack(command, 2) },
          command = command[1],
          cwd = cwd or "${workspaceFolder}",
          current_line = true,
          random_port = true,
          request = "attach",
          error_on_failure = false, -- prevent nvim-dap-ruby from notifying user of exit code 1 from a test with failures.
          localfs = true,
          waiting = 1000,
        }
      end,
    }
    if strategy_config[strategy] then return strategy_config[strategy]() end
  end

  if position.type == "file" then run_by_filename() end

  if position.type == "test" or position.type == "namespace" then run_by_line_number() end

  if position.type == "dir" and vim.bo.filetype == "neotest-summary" then run_by_filename() end

  local command = vim.tbl_flatten({
    config.get_rspec_cmd(position.type),
    script_args,
  })

  return {
    cwd = engine_name,
    command = command,
    context = {
      results_path = results_path,
      engine_name = engine_name,
    },
    strategy = get_strategy_config(args.strategy, command, engine_name),
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
      config.get_rspec_cmd = opts.rspec_cmd
    elseif opts.rspec_cmd then
      config.get_rspec_cmd = function()
        return opts.rspec_cmd
      end
    end
    if is_callable(opts.root_files) then
      config.get_root_files = opts.root_files
    elseif opts.root_files then
      config.get_root_files = function()
        return opts.root_files
      end
    end
    if is_callable(opts.filter_dirs) then
      config.get_filter_dirs = opts.filter_dirs
    elseif opts.filter_dirs then
      config.get_filter_dirs = function()
        return opts.filter_dirs
      end
    end
    if is_callable(opts.transform_spec_path) then
      config.transform_spec_path = opts.transform_spec_path
    elseif opts.transform_spec_path then
      config.transform_spec_path = function()
        return opts.transform_spec_path
      end
    end
    if is_callable(opts.results_path) then
      config.results_path = opts.results_path
    elseif opts.results_path then
      config.results_path = function()
        return opts.results_path
      end
    end
    if is_callable(opts.formatter) then
      config.formatter = opts.formatter
    elseif opts.formatter then
      config.formatter = function()
        return opts.formatter
      end
    end
    return NeotestAdapter
  end,
})

return NeotestAdapter
