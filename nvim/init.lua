if vim.g.vscode then
else
  -- require lua folder
  require('keymap')
  require('option')
  require('autocmd')
  require('plugins.packer')
  require('plugins.lualine')
  require('plugins.treesitter')
  require('plugins.lsp')
  require('plugins.cmp')
  require('plugins.indentBlankLine')
  require('plugins.comment')
end
