-- [[ Colemak: LSP hover ]]
--
-- Neovim puts LSP hover on `K` only when `K` isn't already mapped. motions.lua maps `K`
-- (it does `E`, end of WORD), so this puts hover on `E`, the key `K` moved to.

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('colemak-lsp', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method 'textDocument/hover' then
      vim.keymap.set('n', 'E', vim.lsp.buf.hover, { buf = ev.buf, desc = 'vim.lsp.buf.hover()' })
    end
  end,
})
