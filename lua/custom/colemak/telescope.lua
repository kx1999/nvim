-- [[ Colemak: Telescope picker (normal mode) ]]
--
-- Telescope maps j/k/L inside the picker itself, which override the global swaps in
-- motions.lua. This adds the Colemak equivalents in the picker's normal mode:
--   n  next result      e  previous result      I  last visible result (was L)
-- Telescope's own j/k/L keep working too. Insert mode (<C-n>/<C-p>) is unchanged.

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('colemak-telescope', { clear = true }),
  pattern = 'TelescopePrompt',
  callback = function(ev)
    local actions = require 'telescope.actions'
    local map = function(lhs, action, desc)
      vim.keymap.set('n', lhs, function() actions[action](ev.buf) end, { buf = ev.buf, desc = desc })
    end
    map('n', 'move_selection_next', 'move_selection_next')
    map('e', 'move_selection_previous', 'move_selection_previous')
    map('I', 'move_to_bottom', 'move_to_bottom')
  end,
})
