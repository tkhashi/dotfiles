  -- require lua folder
require('option')
require('keymap')
require('autocmd')
require('plugins.packer')
require('plugins.lualine')
require('plugins.treesitter')
require('plugins.lsp')
require('plugins.cmp')
require('plugins.indentBlankLine')
require('plugins.comment')
if vim.g.vscode then
else
end
