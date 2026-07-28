-- Locate an lcov/gcovr coverage report.
--
-- Resolution is dynamic rather than hardcoded: this project family builds into
-- `_buildresults`, but `builddir`/`build` are also common, and `just coverage`
-- may write to a top-level `coverage/` directory.
local M = {}

local CANDIDATES = {
  -- explicit override
  nil, -- placeholder replaced by vim.g.coverage_file
  -- meson
  "_buildresults/meson-logs/coverage.info",
  "_buildresults_test/meson-logs/coverage.info",
  "builddir/meson-logs/coverage.info",
  "build/meson-logs/coverage.info",
  -- gcovr / lcov conventions
  "coverage/coverage.info",
  "coverage/lcov.info",
  "_buildresults/coverage.info",
  "coverage.info",
  "lcov.info",
}

---@return string|nil absolute path to a readable coverage report
function M.find()
  if vim.g.coverage_file and vim.fn.filereadable(vim.g.coverage_file) == 1 then
    return vim.fn.fnamemodify(vim.g.coverage_file, ":p")
  end

  local marker = vim.fs.find({ ".git", "meson.build", ".justfile" }, { upward = true, path = vim.fn.getcwd() })[1]
  local root = marker and vim.fs.dirname(marker) or vim.fn.getcwd()

  for _, rel in ipairs(CANDIDATES) do
    if rel then
      local path = root .. "/" .. rel
      if vim.fn.filereadable(path) == 1 then
        return path
      end
    end
  end
  return nil
end

return M
