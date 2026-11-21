-- [[ Colemak: core vim motions ]]
--
-- Moves hjkl to the physical QWERTY hjkl positions on Colemak (h n e i) and gives each
-- displaced key the function of the key that took its place:
--
--   n <-> j   (down        / next search match)      N <-> J   (prev match / join lines)
--   e <-> k   (up          / end of word)            E <-> K   (end of WORD / keywordprg, LSP hover)
--   i <-> l   (right       / insert)                 I <-> L   (insert at BOL / bottom of screen)
--
-- Applies in normal, visual and operator-pending modes, so counts and operators follow
-- (`5n` = 5 lines down, `dn` = delete this + next line, `dk` = delete to end of word).
-- In visual/operator-pending mode `l` becomes the "inner" text-object prefix (`clw`, `dl(`)
-- and `i` is the right motion.
--
-- Not touched: g/z/[/] prefixed commands (gj, gk, ge, gi, zj, zk, ...) and insert mode.
--
-- Interactions:
--   * Load `custom.colemak.mini_ai` BEFORE this file so `l` keeps mini.ai's text objects.
--     Without it, `l` falls back to Neovim's built-in text objects only.
--   * Because `K` is now mapped globally, Neovim won't put LSP hover on `K`; use
--     `custom.colemak.lsp` to get hover on `E` instead.

local swaps = {
  { 'n', 'j' }, { 'e', 'k' }, { 'i', 'l' },
  { 'N', 'J' }, { 'E', 'K' }, { 'I', 'L' },
}

-- Labels for each key's original function (which-key's built-in labels where it has one)
local labels = {
  j = 'Down', k = 'Up', l = 'Right',
  n = 'Next search match', e = 'Next end of word', i = 'Insert',
  J = 'Join lines', K = 'Keyword lookup', L = 'Last line of window',
  N = 'Previous search match', E = 'Next end of WORD', I = 'Insert at line start',
}
local label = function(key, mode)
  if key == 'i' and mode ~= 'n' then return 'inside' end
  return labels[key]
end

for _, pair in ipairs(swaps) do
  local a, b = pair[1], pair[2]
  for _, mode in ipairs { 'n', 'x', 'o' } do
    vim.keymap.set(mode, a, b, { desc = label(b, mode) })
    -- Don't clobber a text-object plugin that already claimed `l` (see mini_ai.lua)
    if not (b == 'l' and mode ~= 'n' and vim.fn.maparg('l', mode) ~= '') then
      vim.keymap.set(mode, b, a, { desc = label(a, mode) })
    end
  end
end
