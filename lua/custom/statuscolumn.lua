-- Custom 'statuscolumn', left to right:
--   git signs | fold tree (clickable, outermost level only) | line number | relative number
--
-- Signs and the fold tree only take up space when present; both numbers are always shown.
-- See `:help 'statuscolumn'`

local M = {}

-- Fold levels drawn as lines; deeper folds are hidden (a closed one still shows +)
local MAX_DEPTH = 1
local ICONS = { open = '-', closed = '+', mid = '│', last = '╰' }

-- Neovim's internal fold lookup, the same one the builtin 'foldcolumn' uses.
-- `foldlevel()` can't tell where a fold starts, so without this, sibling folds
-- (e.g. two adjacent `if` blocks) would render as one long line.
local ffi = require 'ffi'
pcall(
  ffi.cdef,
  [[
  typedef struct {} Error;
  typedef struct {} win_T;
  typedef struct { int start; int level; int llevel; int lines; } foldinfo_T;
  foldinfo_T fold_info(win_T *wp, int lnum);
  win_T *find_window_by_handle(int Window, Error *err);
]]
)
local C = ffi.C
local err = ffi.new 'Error'

local NO_FOLD = { start = 0, level = 0, llevel = 0, lines = 0 }

--- start: first line of the deepest fold at lnum, level: its depth,
--- llevel: lowest level that starts at `start`, lines: line count if closed, else 0
local function fold_at(wp, lnum, last)
  if lnum > last then return NO_FOLD end
  return C.fold_info(wp, lnum)
end

-- Width of the fold tree, per window: the deepest fold among the visible lines
local depth_cache = {}

local function visible_depth(win, wp, last)
  local top, bot = vim.fn.line('w0', win), vim.fn.line('w$', win)
  local key = table.concat({ vim.api.nvim_buf_get_changedtick(vim.api.nvim_win_get_buf(win)), top, bot }, ':')
  local cached = depth_cache[win]
  if cached and cached.key == key then return cached end

  local depth, lnum = 0, top
  while lnum <= bot do
    local fi = fold_at(wp, lnum, last)
    depth = math.max(depth, math.min(fi.level, MAX_DEPTH))
    lnum = lnum + math.max(fi.lines, 1)
  end
  cached = { key = key, depth = depth }
  depth_cache[win] = cached
  return cached
end

local function fold_tree(win, wp, lnum, virtnum, last)
  local cache = visible_depth(win, wp, last)
  local fi = fold_at(wp, lnum, last)
  local level = math.min(fi.level, MAX_DEPTH)
  -- Grow if a fold opened since the cache was built; Neovim redraws the column when it widens
  cache.depth = math.max(cache.depth, level)
  if cache.depth == 0 then return '' end

  local closed = fi.lines > 0
  local starts_from = fi.start == lnum and fi.llevel or math.huge
  local next_lnum = lnum + math.max(fi.lines, 1)
  local nxt = fold_at(wp, next_lnum, last)
  local next_starts_from = nxt.start == next_lnum and nxt.llevel or math.huge

  local out = {}
  for k = 1, cache.depth do
    local ends = k > nxt.level or k >= next_starts_from
    local icon
    if k > level then
      icon = nil
    elseif virtnum > 0 then -- wrapped rows of this line
      icon = not ends and ICONS.mid or nil
    elseif virtnum < 0 then -- virtual rows above this line
      icon = k < starts_from and ICONS.mid or nil
    elseif closed and k == level then
      icon = ICONS.closed
    elseif k >= starts_from then
      icon = ICONS.open
    elseif ends then
      icon = ICONS.last
    else
      icon = ICONS.mid
    end
    -- %N@func@ passes N (the clicked level) to the click handler
    out[k] = icon and ('%' .. k .. '@v:lua.StatusColumnFoldClick@' .. icon .. '%X') or ' '
  end
  return '%#FoldColumn#' .. table.concat(out)
end

local function pad(n, width)
  local s = tostring(n)
  return string.rep(' ', width - #s) .. s
end

local function numbers(win, lnum, relnum, virtnum, last)
  local abs_width = math.max(3, #tostring(last))
  local rel_width = math.max(2, #tostring(vim.api.nvim_win_get_height(win)))
  if virtnum ~= 0 then return string.rep(' ', abs_width + rel_width + 2) end

  local cur = relnum == 0
  return table.concat {
    cur and '%#StatusColumnNumCur#' or '%#LineNr#',
    pad(lnum, abs_width),
    ' ',
    cur and '%#StatusColumnRelNumCur#' or '%#StatusColumnRelNum#',
    pad(relnum, rel_width),
    ' ',
  }
end

function M.render()
  local win = vim.g.statusline_winid
  local wp = C.find_window_by_handle(win, err)
  local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win))
  local lnum, relnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
  return '%s' .. fold_tree(win, wp, lnum, virtnum, last) .. numbers(win, lnum, relnum, virtnum, last)
end

-- Left click on the fold tree: open the clicked closed fold, or close the fold at the clicked level
function _G.StatusColumnFoldClick(level, _, button)
  if button ~= 'l' then return end
  local pos = vim.fn.getmousepos()
  local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(pos.winid))
  local fi = fold_at(C.find_window_by_handle(pos.winid, err), pos.line, last)
  local closed = fi.lines > 0
  vim.api.nvim_win_call(pos.winid, function()
    vim.api.nvim_win_set_cursor(0, { pos.line, 0 })
    if closed and level >= math.min(fi.level, MAX_DEPTH) then
      -- Recursive, since closing below also closes the folds nested inside
      vim.cmd 'normal! zO'
    else
      -- `zc` with a count closes that many open levels, from the innermost outwards
      local open_depth = fi.level - (closed and 1 or 0)
      vim.cmd('normal! ' .. (open_depth - level + 1) .. 'zc')
    end
  end)
end

-- Cursor line's number in purple; relative numbers in the theme's foreground color,
-- with the cursor line's 0 in red
local function set_highlights()
  local ok, dracula = pcall(require, 'dracula')
  local colors = ok and dracula.colors() or { fg = '#F8F8F2', red = '#FF5555', purple = '#BD93F9' }
  vim.api.nvim_set_hl(0, 'StatusColumnNumCur', { fg = colors.purple, bold = true })
  vim.api.nvim_set_hl(0, 'StatusColumnRelNum', { fg = colors.fg })
  vim.api.nvim_set_hl(0, 'StatusColumnRelNumCur', { fg = colors.red })
end

function M.setup()
  vim.o.signcolumn = 'auto:1'
  vim.o.foldcolumn = '0' -- the fold tree replaces the builtin fold column
  vim.o.statuscolumn = "%!v:lua.require'custom.statuscolumn'.render()"

  set_highlights()
  local group = vim.api.nvim_create_augroup('custom-statuscolumn', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = set_highlights })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    callback = function(ev) depth_cache[tonumber(ev.match)] = nil end,
  })
end

return M
