local cmd = vim.cmd             -- Execute Vim commands
local exec = vim.api.nvim_exec  -- execute Vimscript
local g = vim.g                 -- global variables
local opt = vim.opt             -- global/buffer/window-scoped options

-- Package manager and plugins to install
require "paq" {
  "savq/paq-nvim",                        -- Let Paq manage itself
  "nvim-treesitter/nvim-treesitter",      -- Better syntax parsing
  "itchyny/lightline.vim",                -- Light and configurable statusline
  "lewis6991/gitsigns.nvim",              -- Git decorations and utilities 
  "unblevable/quick-scope",               -- Highlight unique characters in current line
  "huyvohcmc/atlas.vim",                  -- Minimal colorscheme (no accent color)
  "ewilazarus/preto",                     -- Minimal colorscheme (more shades of gray)
  "kadekillary/skull-vim",                -- Minimal colorscheme (nice green accent)
  "ellisonleao/gruvbox.nvim",             -- gruvbox theme

  "lervag/vimtex",                        -- TeX support

  "nvim-lua/plenary.nvim",                -- Telescope dependency
  "nvim-telescope/telescope.nvim",        -- Fuzzy finder
  "nvim-telescope/telescope-fzy-native.nvim" ,  -- Sorter for Telescope

  "neovim/nvim-lspconfig",                -- LSP
  "nvim-lua/lsp-status.nvim",             -- Status for LSP

  "hrsh7th/cmp-nvim-lsp",                 -- Completion of code
  "hrsh7th/cmp-buffer",                   -- 
  "hrsh7th/cmp-path",                     -- Path completion
  "hrsh7th/cmp-cmdline",
  "hrsh7th/nvim-cmp",
  "dcampos/nvim-snippy",
  "dcampos/cmp-snippy",
}

require('nvim-treesitter.configs').setup {
  -- A list of parser names ("all" for everyone)
  ensure_installed = { "c", "cpp", "rust", "lua", "hare" },

  -- Automatically install missing parsers when entering buffer
  auto_install = false,

  highlight = {
    enable = true,

    -- List of parsers to disable
    -- disable = {},

    -- Additional highlight with regexp rules for specified languages
    -- additional_vim_regex_highlighting = {}
  },
}

require('telescope').setup {
  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    }
  }
}

require('telescope').load_extension('fzy_native')

--[[
require('snippy').setup {
    mappings = {
        is = {
            ['<Tab>'] = 'expand_or_advance',
            ['<S-Tab>'] = 'previous',
        },
        nx = {
            ['<leader>x'] = 'cut_text',
        },
    },
}
--]]

local cmp = require('cmp')
local snippy = require("snippy")
local lspconfig = require('lspconfig')
local lsp_status = require('lsp-status')

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup {
  snippet = {
    expand = function(args)
      snippy.expand_snippet(args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif snippy.can_expand_or_advance() then
        snippy.expand_or_advance()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif snippy.can_jump(-1) then
        snippy.previous()
      else
        fallback()
      end
    end, { "i", "s" }),

    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'snippy' },
    { name = 'buffer' }
  })
}

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
    { name = 'cmdline' }
  })
})

local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.clangd.setup {
  handlers = lsp_status.extensions.clangd.setup(),
  init_options = {
    clangdFileStatus = true
  },
  on_attach = lsp_status.on_attach,
  capabilities = {
    lsp_status.capabilities,
    cmp_capabilities
  }
}

lspconfig.neocmake.setup {
  on_attach = lsp_status.on_attach,
  capabilities = lsp_status.capabilities
}

lspconfig.rust_analyzer.setup {
  on_attach = lsp_status.on_attach,
  capabilities = lsp_status.capabilities
}

require('gitsigns').setup {
  -- Signs and their colors
  signs = {
    add             = {hl = 'GitSignsAdd'   , text = '▌', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change          = {hl = 'GitSignsChange', text = '▌', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete          = {hl = 'GitSignsDelete', text = '▁', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete       = {hl = 'GitSignsDelete', text = '▔', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete    = {hl = 'GitSignsChange', text = '▌', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
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
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
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

require('gruvbox').setup {
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

-- Main options
opt.cursorline = true           -- Cursor line highlight
opt.colorcolumn = '80'          -- Vertical line
opt.number = true               -- Number column on the left
opt.hidden = true               -- Allow switching without saving
opt.signcolumn = 'yes'          -- Additional line for signs on the left is always visible
opt.relativenumber = true

-- Identation settings
opt.expandtab = false
opt.tabstop = 8
opt.smartindent = true

g.vimtex_view_method = 'zathura'

cmd([[
syntax enable
set termguicolors 
colorscheme skull

let g:lightline = { 'colorscheme': 'atlas' }
let g:c_syntax_for_h = 1

let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
let g:qs_max_chars=200
highlight QuickScopePrimary guifg='#7ede81' gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#ffffff' gui=underline ctermfg=81 cterm=underline
 
let g:vimtex_view_method = 'zathura'
let g:vimtex_compiler_latexmk = {
\ 'build_dir': 'output',
\}

autocmd BufRead,BufNewFile *.cppm set filetype=cpp
autocmd BufRead,BufNewFile *.cppp set filetype=cpp
autocmd BufRead,BufNewFile *.ixx set filetype=cpp

function! LspStatus() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return luaeval("require('lsp-status').status()")
  endif

  return ''
endfunction
]])

