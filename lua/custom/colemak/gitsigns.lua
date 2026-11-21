-- [[ Colemak: gitsigns hunk text object ]]
--
-- Moves the buffer-local `ih` (inner hunk) text object to `lh`, matching the
-- `i` -> `l` inner prefix change in mini_ai.lua / motions.lua.
-- Works by wrapping gitsigns' on_attach, so your init.lua gitsigns config is untouched.

local ok, gs_config = pcall(require, 'gitsigns.config')
if not ok then return end

local cfg = gs_config.config
local user_on_attach = cfg.on_attach

cfg.on_attach = function(bufnr)
  local res = user_on_attach and user_on_attach(bufnr)
  pcall(vim.keymap.del, { 'o', 'x' }, 'ih', { buf = bufnr })
  vim.keymap.set({ 'o', 'x' }, 'lh', function() require('gitsigns').select_hunk() end, { buf = bufnr, desc = 'text object [i]nside [h]unk' })
  return res
end
