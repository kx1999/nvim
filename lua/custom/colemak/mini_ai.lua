-- [[ Colemak: mini.ai text objects ]]
--
-- Moves mini.ai's "inside" text-object prefix from `i` to `l` (visual + operator-pending),
-- matching motions.lua where `i` became the right motion:
--
--   i  -> l    inside            (`ciw` is now `clw`, `vi(` is now `vl(`)
--   ii -> ll   inside next       (your init.lua sets inside_next = 'ii')
--   il -> li   inside last
--   `a`, `aa`, `al` (around) are unchanged.
--
-- Built-in fallbacks (w, W, s, p) still work: mini.ai's callbacks are reused as-is.
-- Must be required AFTER mini.ai's setup() and BEFORE custom.colemak.motions.

if not package.loaded['mini.ai'] then return end

local moves = { i = 'l', ii = 'll', il = 'li' }

for _, mode in ipairs { 'x', 'o' } do
  for from, to in pairs(moves) do
    local m = vim.fn.maparg(from, mode, false, true)
    if m.callback then
      vim.keymap.del(mode, from)
      vim.keymap.set(mode, to, m.callback, { expr = true, desc = m.desc })
    end
  end
end
