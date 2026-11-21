-- [[ Colemak: window navigation ]]
--
-- Kickstart's CTRL+<hjkl> window focus moves to CTRL+<h n e i>, and the displaced
-- CTRL keys get the built-in function of the key that took their place:
--
--   <C-n> focus lower window      <C-j> built-in <C-n> (cursor down a line)
--   <C-e> focus upper window      <C-k> built-in <C-e> (scroll window down a line)
--   <C-i> focus right window      <C-l> built-in <C-i> (jump forward in jumplist)
--   <C-h> unchanged
--
-- NOTE: most terminals send the same code for <C-i> and <Tab>, so <Tab> in normal mode
-- also focuses the right window (both used to jump forward; that now lives on <C-l>).
--
-- The same swap applies after the <C-w> prefix (with or without CTRL held on the 2nd key):
--   <C-w>n/e/i      focus down/up/right       <C-w>j/k/l  get old <C-w>n (new window) / nothing / <C-w>i
--   <C-w>N/E/I      move window down/up/right <C-w>J/K/L  unbound (nothing to swap with)

local map = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end

-- Kickstart's CTRL+direction focus maps (overrides the ones in init.lua)
map('<C-n>', '<C-w><C-j>', 'Move focus to the lower window')
map('<C-e>', '<C-w><C-k>', 'Move focus to the upper window')
map('<C-i>', '<C-w><C-l>', 'Move focus to the right window')
map('<C-j>', '<C-n>', 'Down')
map('<C-k>', '<C-e>', 'Scroll down a line')
map('<C-l>', '<C-i>', 'Jump forward')

-- <C-w> + key, lowercase and CTRL-held variants
for _, ctrl in ipairs { false, true } do
  local k = function(c) return ctrl and ('<C-' .. c .. '>') or c end
  map('<C-w>' .. k 'n', '<C-w>' .. k 'j', 'Go to the down window')
  map('<C-w>' .. k 'j', '<C-w>' .. k 'n', 'New window')
  map('<C-w>' .. k 'e', '<C-w>' .. k 'k', 'Go to the up window')
  map('<C-w>' .. k 'k', '<Nop>')
  map('<C-w>' .. k 'i', '<C-w>' .. k 'l', 'Go to the right window')
  map('<C-w>' .. k 'l', '<C-w>' .. k 'i', 'Split and jump to declaration')
end

-- <C-w> + uppercase: move the window itself
map('<C-w>N', '<C-w>J', 'Move window to far bottom')
map('<C-w>E', '<C-w>K', 'Move window to far top')
map('<C-w>I', '<C-w>L', 'Move window to far right')
map('<C-w>J', '<Nop>')
map('<C-w>K', '<Nop>')
map('<C-w>L', '<Nop>')
