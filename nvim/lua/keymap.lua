-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', '<Esc><Esc>', ':nohl<CR>')


-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

--vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])
-- For easy to use :terminal
local opts = { noremap = true }

-- Terminal mode remapping
vim.keymap.set('t', '<ESC>', [[<C-\><C-n>]], opts)

-- Normal mode remappings for window management
local keymap_definitions = {
    {'n', '<C-W>n', '<cmd>new<CR>', opts},
    {'n', '<C-W><C-N>', '<cmd>new<CR>', opts},
    {'n', '<C-W>q', '<cmd>quit<CR>', opts},
    {'n', '<C-W><C-Q>', '<cmd>quit<CR>', opts},
    {'n', '<C-W>c', '<cmd>close<CR>', opts},
    {'n', '<C-W>o', '<cmd>only<CR>', opts},
    {'n', '<C-W><C-O>', '<cmd>only<CR>', opts},
    {'n', '<C-W><Down>', '<cmd>wincmd j<CR>', opts},
    {'n', '<C-W><C-J>', '<cmd>wincmd j<CR>', opts},
    {'n', '<C-W>j', '<cmd>wincmd j<CR>', opts},
    {'n', '<C-W><Up>', '<cmd>wincmd k<CR>', opts},
    {'n', '<C-W><C-K>', '<cmd>wincmd k<CR>', opts},
    {'n', '<C-W>k', '<cmd>wincmd k<CR>', opts},
    {'n', '<C-W><Left>', '<cmd>wincmd h<CR>', opts},
    {'n', '<C-W><C-H>', '<cmd>wincmd h<CR>', opts},
    {'n', '<C-W><BS>', '<cmd>wincmd h<CR>', opts},
    {'n', '<C-W>h', '<cmd>wincmd h<CR>', opts},
    {'n', '<C-W><Right>', '<cmd>wincmd l<CR>', opts},
    {'n', '<C-W><C-L>', '<cmd>wincmd l<CR>', opts},
    {'n', '<C-W>l', '<cmd>wincmd l<CR>', opts},
    {'n', '<C-W>w', '<cmd>wincmd w<CR>', opts},
    {'n', '<C-W><C-W>', '<cmd>wincmd w<CR>', opts},
    {'n', '<C-W>W', '<cmd>wincmd W<CR>', opts},
    {'n', '<C-W>t', '<cmd>wincmd t<CR>', opts},
    {'n', '<C-W><C-T>', '<cmd>wincmd t<CR>', opts},
    {'n', '<C-W>b', '<cmd>wincmd b<CR>', opts},
    {'n', '<C-W><C-B>', '<cmd>wincmd b<CR>', opts},
    {'n', '<C-W>p', '<cmd>wincmd p<CR>', opts},
    {'n', '<C-W><C-P>', '<cmd>wincmd p<CR>', opts},
    {'n', '<C-W>P', '<cmd>wincmd P<CR>', opts},
    {'n', '<C-W>r', '<cmd>wincmd r<CR>', opts},
    {'n', '<C-W><C-R>', '<cmd>wincmd r<CR>', opts},
    {'n', '<C-W>R', '<cmd>wincmd R<CR>', opts},
    {'n', '<C-W>x', '<cmd>wincmd x<CR>', opts},
    {'n', '<C-W><C-X>', '<cmd>wincmd x<CR>', opts},
    {'n', '<C-W>K', '<cmd>wincmd K<CR>', opts},
    {'n', '<C-W>J', '<cmd>wincmd J<CR>', opts},
    {'n', '<C-W>H', '<cmd>wincmd H<CR>', opts},
    {'n', '<C-W>L', '<cmd>wincmd L<CR>', opts},
    {'n', '<C-W>T', '<cmd>wincmd T<CR>', opts},
    {'n', '<C-W>=', '<cmd>wincmd =<CR>', opts},
    {'n', '<C-W>-', '<cmd>wincmd -<CR>', opts},
    {'n', '<C-W>+', '<cmd>wincmd +<CR>', opts},
    {'n', '<C-W>z', '<cmd>pclose<CR>', opts},
    {'n', '<C-W><C-Z>', '<cmd>pclose<CR>', opts}
}

for _, map in ipairs(keymap_definitions) do
    vim.keymap.set(map[1], map[2], map[3], map[4])
end
