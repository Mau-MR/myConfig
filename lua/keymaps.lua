-- Custom configuration
vim.o.showmode = false
vim.o.autowriteall = true
vim.g.mapleader=' '
vim.wo.number = true
vim.wo.relativenumber =true
vim.opt.list = true
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'
vim.o.termguicolors = true
vim.o.completeopt = 'menu,menuone'

local function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', "<Leader>w", ":w<CR>", { silent = true })
map('n', "<Leader>q", ":wq<CR>", { silent = true })
map('i', "jj", "<ESC>", { silent = true })
--Some Telescope features, more keybindings on the telescope file
map('n', "<Leader>ff", ":Telescope find_files<cr>", { silent = true })
map('n', "<Leader>fg", ":Telescope live_grep<cr>", { silent = true })
map('n', "<Leader>fb", ":Telescope buffers<cr>", { silent = true })
map('n', "<Leader>fh", ":Telescope help_tags<cr>", { silent = true })

-- Highlight on yank
vim.cmd [[
augroup YankHighlight
autocmd!
autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup end
]]
