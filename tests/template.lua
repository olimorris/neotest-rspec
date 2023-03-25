local Path = require("plenary.path")
local scandir = require("plenary.scandir")
local test_utils = require("tests.utils")

local cwd = vim.loop.cwd()

local function assert_skipped(reason)
  error("SKIPPED: " .. reason, 0)
end

local function for_each_test_file(test, callback)
  local files = scandir.scan_dir(Path:new(cwd, "spec"):absolute())
  for _, file in pairs(files) do
    if string.match(file, test) then
      callback(file)
    end
  end
end

local function for_each_command(test, callback)
  -- Get the parent directory of the test file
  local path = Path:new(test):parent()

  for _, file in pairs(scandir.scan_dir(path:absolute())) do
    if string.match(file, "%.commands") then
      local parts = test_utils.split_string(file, "%.")
      local command = parts[1]
      callback(command)
    end
  end
end

local M = {}

function M.describe(describing, name)
  describe(describing, function()
    for_each_test_file(name, function(test)
      test_utils.open_test_file(test)

      for_each_command(test, function(command)
        it(string.format("(file: %s)", command), function()
          local expected = test_utils.get_contents(string.format("%s.expected", command))
          if not expected then return assert_skipped("Could not find expected output file") end

          local co = coroutine.running()
          vim.defer_fn(function()
            coroutine.resume(co)
          end, 1000)

          test_utils.run_commands(command)
          coroutine.yield()

          -- Get the test output from the custom consumer
          assert.are.same(expected, TEST_OUTPUT)
        end)
      end)
    end)
  end)
end

return M
