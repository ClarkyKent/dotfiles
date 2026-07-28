-- Treesitter incremental selection with a real selection stack.
--
-- The previous implementation expanded to the immediate parent only and mapped
-- <BS> to `normal! o`, which just swaps the ends of the visual selection rather
-- than shrinking it.
local M = {}

---Per-buffer stack of {start_row, start_col, end_row, end_col} ranges.
---@type table<integer, table[]>
local stacks = {}

local function clear(bufnr)
  stacks[bufnr] = nil
end

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = vim.api.nvim_create_augroup("ts_incremental", { clear = true }),
  callback = function(args)
    clear(args.buf)
  end,
})

---@return integer, integer, integer, integer
local function visual_range()
  local s = vim.fn.getpos("v")
  local e = vim.fn.getpos(".")
  local sr, sc = s[2] - 1, s[3] - 1
  local er, ec = e[2] - 1, e[3] - 1
  if sr > er or (sr == er and sc > ec) then
    sr, sc, er, ec = er, ec, sr, sc
  end
  return sr, sc, er, ec
end

local function select_range(range)
  local sr, sc, er, ec = range[1], range[2], range[3], range[4]
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd("normal! v")
  -- end_col from a treesitter range is exclusive
  vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
end

local function in_visual()
  return vim.fn.mode():find("^[vV\22]") ~= nil
end

function M.expand()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    -- No parser: fall back to plain word selection so the key is never dead.
    if not in_visual() then
      vim.cmd("normal! viw")
    end
    return
  end

  local node
  if in_visual() then
    local sr, sc, er, ec = visual_range()
    stacks[bufnr] = stacks[bufnr] or {}
    if #stacks[bufnr] == 0 then
      table.insert(stacks[bufnr], { sr, sc, er, ec })
    end
    node = vim.treesitter.get_node({ bufnr = bufnr, pos = { sr, sc } })
    -- Walk up until we find a node strictly larger than the current selection.
    while node do
      local nsr, nsc, ner, nec = node:range()
      if (nsr < sr or (nsr == sr and nsc < sc)) or (ner > er or (ner == er and nec > ec)) then
        break
      end
      node = node:parent()
    end
  else
    stacks[bufnr] = {}
    local cursor = vim.api.nvim_win_get_cursor(0)
    node = vim.treesitter.get_node({ bufnr = bufnr, pos = { cursor[1] - 1, cursor[2] } })
  end

  if not node then
    return
  end

  local range = { node:range() }
  table.insert(stacks[bufnr], range)
  select_range(range)
end

function M.shrink()
  local bufnr = vim.api.nvim_get_current_buf()
  local stack = stacks[bufnr]
  if not stack or #stack < 2 then
    return
  end
  table.remove(stack) -- discard current
  select_range(stack[#stack])
end

return M
