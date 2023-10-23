-- Bootstrap lazy.nvim plugin manager
--
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Setup plugin manager
--
require("lazy").setup({
  -- Colorschemes
  "ellisonleao/gruvbox.nvim",
  "kxzk/skull-vim",
  -- Treesitter for better code parsing
  "nvim-treesitter/nvim-treesitter",
  -- Code completion and LSP
  "neovim/nvim-lspconfig",
  "nvim-lua/lsp-status.nvim",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/nvim-cmp",
  -- Snippets
  "L3MON4D3/LuaSnip",
  -- Statusline
  "nvim-lualine/lualine.nvim",
  -- Git signs
  "lewis6991/gitsigns.nvim",
})

-- General settings
--
vim.highlight.on_yank = true
vim.o.mouse = 'a'
vim.o.number = true
vim.o.relativenumber = true
vim.o.textwidth = 80
vim.o.cursorline = true
vim.o.cursorcolumn = false
vim.o.colorcolumn = '80'
vim.o.signcolumn = 'yes'
vim.o.title = true
vim.o.scrolloff = 3
vim.o.termguicolors = true
vim.opt.expandtab = false
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8
vim.opt.smartindent = true
vim.cmd("set nofoldenable")
vim.cmd("let g:c_syntax_for_h = 1")

-- Colorscheme
--
require("gruvbox").setup {
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "soft", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
}
vim.cmd("colorscheme gruvbox")

-- Code completion settings
--
vim.o.completeopt = 'menu,menuone,noselect'

local luasnip = require("luasnip")
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
    },
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }
  }, {
    { name = 'buffer' },
    { name = 'path' }
  })
})

-- LSP configuration
--
local lspconfig = require("lspconfig")

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'clangd', 'pylsp', 'rust_analyzer' }
for _, lsp in pairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities
  }
end

-- Statusline configuration
--
require("lualine").setup({
  options = {
    theme = require("lualine.themes.gruvbox"),
    section_separators = '',
    component_separators = ''
  }
})

-- Treesitter configuration
--
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "rust", "lua", "hare" },

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  highlight = {
    enable = true,
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = { enable = false }
})

-- Setup folding based on treesitter
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldnestmax = 1

-- Git signs configuration
-- 
require('gitsigns').setup {
  -- Signs and their colors
  signs = {
    add = {
      hl = 'GitSignsAdd',
      text = '▌',
      numhl='GitSignsAddNr',
      linehl='GitSignsAddLn'
    },
    change = {
      hl = 'GitSignsChange',
      text = '▌',
      numhl='GitSignsChangeNr',
      linehl='GitSignsChangeLn'
    },
    delete = {
      hl = 'GitSignsDelete',
      text = '▁',
      numhl='GitSignsDeleteNr',
      linehl='GitSignsDeleteLn'
    },
    topdelete = {
      hl = 'GitSignsDelete',
      text = '▔',
      numhl='GitSignsDeleteNr',
      linehl='GitSignsDeleteLn'
    },
    changedelete = {
      hl = 'GitSignsChange',
      text = '▌',
      numhl='GitSignsChangeNr',
      linehl='GitSignsChangeLn'
    },
  },

  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`

  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },

  attach_to_untracked = true,
  current_line_blame = true,  -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },

  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 10000,

  -- Options passed to nvim_open_win
  preview_config = {
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },

  yadm = {
    enable = false
  },
}

vim.keymap.set('n', '<space>ghr', ':Gitsigns reset_hunk<CR>', opts)

