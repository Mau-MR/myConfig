-- Packer installation
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute(
    '!git clone https://github.com/wbthomason/packer.nvim ' .. install_path
  )
end

vim.cmd [[
augroup Packer
  autocmd!
  autocmd BufWritePost init.lua PackerCompile
augroup end
]]

-- Plugin installation
local use = require("packer").use
require("packer").startup(function()
  -- Package manager
  use 'wbthomason/packer.nvim'

  -- LSP Client
  use 'neovim/nvim-lspconfig'

  -- Language Server installer
  use {
    'williamboman/nvim-lsp-installer',
    requires = 'neovim/nvim-lspconfig',
  }
  use {
  'nvim-telescope/telescope.nvim',
  requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- BONUS: Customizations over LSP
  -- Show VSCode-esque pictograms
  use 'onsails/lspkind-nvim'
  -- show various elements of LSP as UI
  use {'tami5/lspsaga.nvim', requires = {'neovim/nvim-lspconfig'}}

  -- Autocompletion plugin
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
    }
  }

  -- snippets
  use {
    'hrsh7th/cmp-vsnip', requires = {
      'hrsh7th/vim-vsnip',
      'rafamadriz/friendly-snippets',
    }
  }

  -- bracket autocompletion
  use 'vim-scripts/auto-pairs-gentle'

  -- Fancier statusline
  use {
    'nvim-lualine/lualine.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons',
      'arkav/lualine-lsp-progress',
    },
  }

  -- Fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'

  -- Beautiful colorscheme
  use 'navarasu/onedark.nvim'
end)
require("keymaps")
require('lspconfig')
require('telescope')
local lsp_installer = require("nvim-lsp-installer")

-- The required servers
local servers = {
  "bashls",
  "pyright",
  "rust_analyzer",
  "sumneko_lua",
  "html",
  "clangd",
  "vimls",
  "emmet_ls",
}

for _, name in pairs(servers) do
  local server_is_found, server = lsp_installer.get_server(name)
  if server_is_found and not server:is_installed() then
    print("Installing " .. name)
    server:install()
  end
end

local on_attach = function(_, bufnr)
  -- Create some shortcut functions.
  -- NOTE: The `vim` variable is supplied by Neovim.
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = {noremap=true, silent=true}

  -- ======================= The Keymaps =========================
  -- jump to definition
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)

  -- Format buffer
  buf_set_keymap('n', '<F3>', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  -- Jump LSP diagnostics
  -- NOTE: Currently, there is a bug in lspsaga.diagnostic module. Thus we use
  --       Vim commands to move through diagnostics.
  buf_set_keymap('n', '[g', ':Lspsaga diagnostic_jump_prev<CR>', opts)
  buf_set_keymap('n', ']g', ':Lspsaga diagnostic_jump_next<CR>', opts)

  -- Rename symbol
  buf_set_keymap('n', '<leader>rn', "<cmd>lua require('lspsaga.rename').rename()<CR>", opts)

  -- Find references
  buf_set_keymap('n', 'gr', '<cmd>lua require("lspsaga.provider").lsp_finder()<CR>', opts)

  -- Doc popup scrolling
  buf_set_keymap('n', 'K', "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", opts)
  buf_set_keymap('n', '<C-f>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", opts)
  buf_set_keymap('n', '<C-b>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", opts)

  -- codeaction
  buf_set_keymap('n', '<leader>ac', "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts)
  buf_set_keymap('v', '<leader>a', ":<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>", opts)

  -- Floating terminal
  -- NOTE: Use `vim.cmd` since `buf_set_keymap` is not working with `tnoremap...`
  vim.cmd [[
  nnoremap <silent> <A-d> <cmd>lua require('lspsaga.floaterm').open_float_terminal()<CR>
  tnoremap <silent> <A-d> <C-\><C-n>:lua require('lspsaga.floaterm').close_float_terminal()<CR>
  ]]
end

local server_specific_opts = {
  sumneko_lua = function(opts)
    opts.settings = {
      Lua = {
        -- NOTE: This is required for expansion of lua function signatures!
        completion = {callSnippet = "Replace"},
        diagnostics = {
          globals = {'vim'},
        },
      },
    }
  end,

  html = function(opts)
    opts.filetypes = {"html", "htmldjango"}
  end,
}

-- `nvim-cmp` comes with additional capabilities, alongside the ones
-- provided by Neovim!
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

lsp_installer.on_server_ready(function(server)
  -- the keymaps, flags and capabilities that will be sent to the server as
  -- options.
  local opts = {
    on_attach = on_attach,
    flags = {debounce_text_changes = 150},
    capabilities = capabilities,
  }

  -- If the current surver's name matches with the ones specified in the
  -- `server_specific_opts`, set the options.
  if server_specific_opts[server.name] then
    server_specific_opts[server.name](opts)
  end

  -- And set up the server with our configuration!
  server:setup(opts)
end)

-- nvim-cmp
local cmp = require("cmp")

local has_words_before = function()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end


cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },

  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },

    -- Use Tab and Shift-Tab to browse through the suggestions.
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end, { "i", "s" }),
  },

  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
  },
})

-- Use buffer source for `/`
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- autopairs
vim.g.AutoPairs = {
  ['(']=')',
  ['[']=']',
  ['{']='}',
  ["'"]="'",
  ['"']='"',
  ['`']='`',
  ['<']='>',
}

-- onedark
require("onedark").setup({
  style = "darker",
})
require('onedark').load()

-- lualine
require('lualine').setup({
  sections = {
    lualine_c = {
      {'filename', path = 1},
      'lsp_progress',
    },
  },
})

-- treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {"python", "rust", "c", "cpp", "bash", "go", "html"},
  highlight = {
    enable = true, -- false will disable the whole extension
  },
}

-- lspsaga
require("lspsaga").init_lsp_saga({
  finder_action_keys = {
    open = '<CR>',
    quit = {'q', '<esc>'},
  },
  code_action_keys = {
    quit = {'q', '<esc>'},
  },
  rename_action_keys = {
    quit = '<esc>',
  },
})
