-- [[ Setting options ]]
-- See `:help vim.o`

vim.o.hlsearch = true -- Set highlight on search
vim.wo.number = true -- Make line numbers default
vim.o.mouse = 'a' -- Enable mouse mode
vim.o.clipboard = 'unnamedplus' -- Share OS clipboard
vim.o.breakindent = true -- Enable break indent
vim.o.undofile = true -- Save undo history
vim.o.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.o.smartcase = true
vim.o.updatetime = 250 -- Decrease update time
vim.wo.signcolumn = 'yes'
vim.o.termguicolors = true -- Set colorscheme
--vim.cmd [[colorscheme onedark]]
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

