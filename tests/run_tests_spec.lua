local a = require("plenary.async").tests
local Path = require("plenary.path")
local scandir = require("plenary.scandir")
local test_utils = require("tests.utils")

local async = require("plenary.async")

local cwd = vim.loop.cwd()
vim.cmd("set rtp+=" .. cwd)

local eq = assert.are.same

local tests_to_skip = {}

local function remove_cwd(file)
  return file:sub(#cwd + 2 + #"lua/refactoring/tests/")
end

local function for_each_file(cb)
  local files = scandir.scan_dir(Path:new(cwd, "spec"):absolute())
  for _, file in pairs(files) do
    if string.match(file, "start") and not test_utils.check_if_skip_test(file, tests_to_skip) then
      cb(file)
    end
  end
end

describe("Testing", function()
  for_each_file(function(file)
    it(string.format("File: %s", file), function()
      local parts = test_utils.split_string(file, "%.")
      local filename_prefix = parts[1]

      -- Delete the test results
      os.remove(cwd .. "/tests/test_output.txt")

      local bufnr = test_utils.open_test_file(file)
      local expected = test_utils.get_contents(string.format("%s.expected", filename_prefix))

      local co = coroutine.running()
      vim.defer_fn(function()
        coroutine.resume(co)
      end, 1000)

      test_utils.run_commands(filename_prefix)
      coroutine.yield()

      local output_file = io.open(cwd .. "/tests/test_output.txt", "r")
      print(cwd)
      local output = test_utils.split_string(output_file:read("*a"), "\n")
      output_file:close()

      eq(expected, output)
    end)
  end)
end)
