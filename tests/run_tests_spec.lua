local Path = require("plenary.path")
local scandir = require("plenary.scandir")
local test_utils = require("tests.utils")

local cwd = vim.loop.cwd()
vim.cmd("set rtp+=" .. cwd)

local eq = assert.are.same

local tests_to_skip = {}

local function assert_skipped(reason)
  error("SKIPPED: " .. reason, 0)
end

local function for_each_test_file(callback)
  local files = scandir.scan_dir(Path:new(cwd, "spec"):absolute())
  for _, file in pairs(files) do
    -- file = remove_cwd(file)
    if string.match(file, "_spec%.rb") and not test_utils.check_if_skip_test(file, tests_to_skip) then callback(file) end
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

describe("Testing", function()
  for_each_test_file(function(test)
    for_each_command(test, function(command)
      local bufnr = test_utils.open_test_file(test)
      it(string.format("File: %s", command), function()
        local expected = test_utils.get_contents(string.format("%s.expected", command))
        if not expected then return assert_skipped("Could not find expected output file") end

        local co = coroutine.running()
        vim.defer_fn(function()
          coroutine.resume(co)
        end, 1000)

        test_utils.run_commands(command)
        coroutine.yield()

        -- Get the test output from the custom consumer
        eq(expected, TEST_OUTPUT)
      end)
    end)
  end)
end)
