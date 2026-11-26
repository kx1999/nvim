 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#171926',
    base01 = '#1e2133',
    base02 = '#262a40',
    base03 = '#626572',
    base04 = '#afb0b6',
    base05 = '#f2f2f3',
    base06 = '#f2f2f3',
    base07 = '#f2f2f3',
    base08 = '#fd4663',
    base09 = '#bf66cc',
    base0A = '#8a5cd6',
    base0B = '#6778e4',
    base0C = '#de96e9',
    base0D = '#939fec',
    base0E = '#b596e9',
    base0F = '#d2bef4',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#f2f2f3',          bg = '#171926' })
  hi('TelescopeBorder',         { fg = '#626572',             bg = '#171926' })
  hi('TelescopePromptNormal',   { fg = '#f2f2f3',          bg = '#171926' })
  hi('TelescopePromptBorder',   { fg = '#626572',             bg = '#171926' })
  hi('TelescopePromptPrefix',   { fg = '#6778e4',             bg = '#171926' })
  hi('TelescopePromptCounter',  { fg = '#afb0b6',  bg = '#171926' })
  hi('TelescopePromptTitle',    { fg = '#171926',             bg = '#6778e4' })
  hi('TelescopePreviewTitle',   { fg = '#171926',             bg = '#8a5cd6' })
  hi('TelescopeResultsTitle',   { fg = '#171926',             bg = '#bf66cc' })
  hi('TelescopeSelection',      { fg = '#f2f2f3',          bg = '#262a40' })
  hi('TelescopeSelectionCaret', { fg = '#6778e4',             bg = '#262a40' })
  hi('TelescopeMatching',       { fg = '#6778e4',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#f2f2f3',          bg = '#171926' })
  hi('MiniPickBorder',         { fg = '#626572',             bg = '#171926' })
  hi('MiniPickPrompt',   { fg = '#f2f2f3',          bg = '#171926' })
  hi('MiniPickPromptPrefix',   { fg = '#6778e4',             bg = '#171926' })
  hi('MiniPickBorderText',    { fg = '#171926',             bg = '#6778e4' })
  hi('MiniPickMatchCurrent',      { fg = '#f2f2f3',          bg = '#262a40' })
  hi('MiniPickPromptCaret', { fg = '#6778e4',             bg = '#262a40' })
  hi('MiniPickMatchRanges',       { fg = '#6778e4',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
