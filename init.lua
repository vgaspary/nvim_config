-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

local function find_file_under_cursor()
  local filename = vim.fn.expand('<cfile>')
  require('telescope.builtin').find_files({
    default_text = filename
  })
end

vim.opt.rtp:prepend(lazypath)
vim.opt.termguicolors = true

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loadad_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
        on_highlights = function(hl, c)
          local line_nr_color = "#767d9c"
          hl.LineNr = {
            fg = line_nr_color
          }
          hl.LineNrAbove = {
            fg = line_nr_color
          }
          hl.LineNrBelow = {
            fg = line_nr_color
          }
        end
      },
    },

    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},
    {'sindrets/diffview.nvim'}, 
    {'nvim-treesitter/nvim-treesitter', branch = 'master', lazy = false, build = ":TSUpdate"},
    {
      'neovim/nvim-lspconfig',
      lazy = false,
    },
    {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      config = function()
        require("nvim-tree").setup {
          git = {
            ignore = false,
          }
        }
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      tag = '0.1.8',
      dependencies = {
        "nvim-lua/plenary.nvim"
      },
      config = function()
        require("telescope").setup({
          defaults = {
            hidden = true,
            no_ignore = true,
          }
        })
      end,
    },
    {
      "nvimtools/hydra.nvim",
      config = function()
        local Hydra = require("hydra")

        Hydra({
          name = "Window Resize",
          mode = "n",
          body = "<C-w>r",
          heads = {
            { "j", "<C-w>+" },
            { "k", "<C-w>-" },
            { "h", "<C-w><" },
            { "l", "<C-w>>" },
            { "<Esc>", nil, { exit = true } },
            { "<CR>", nil, { exit = true } },
          }
        })
      end
    },
    {
      "OXY2DEV/markview.nvim",
      lazy = false,
    },
    {
      "3rd/image.nvim",
      build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
      opts = {
        processor = "magick_cli",
      }
    }
  },

  -- automatically check for plugin updates
  checker = { enabled = true },
})

vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.guicursor = {
  "i-n-v-c-sm:block-Cursor/lCursor",
}

vim.api.nvim_create_autocmd("TermOpen", { pattern = "*", command = "startinsert" })
vim.keymap.set('n', 'j', "gj", { noremap = true })
vim.keymap.set('n', 'k', "gk", { noremap = true })
vim.keymap.set('v', 'p', '"_dP', { noremap = true })
vim.keymap.set('v', '<S-j>', ":m '>+1<cr>gv=gv", { noremap = true })
vim.keymap.set('v', '<S-k>', ":m '<-2<cr>gv=gv", { noremap = true })
vim.keymap.set('t', '<Esc><Esc>', "<C-\\><C-n>", { noremap = true })
vim.keymap.set('n', '<leader>tt', ":botright split | term<cr>", { noremap = true })
vim.keymap.set('n', '<leader>gg', ":botright vsplit | vertical resize 100 | term<cr>agy<cr>", { noremap = true })
vim.keymap.set('n', '<leader>r', "<cmd>.w !bash<cr>", { noremap = true })
vim.keymap.set('n', '<leader>jf', '<cmd>%!jq .<cr>', { noremap = true})
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true})
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true})
vim.keymap.set('n', '<leader>mm', '<cmd>Markview<cr>', { noremap = true})
vim.keymap.set('n', '<leader>ms', '<cmd>Markview splitToggle<cr>', { noremap = true})
vim.keymap.set('n', '<leader>gf', find_file_under_cursor, { noremap = true, silent = true })
-- Live grep the visual selection
vim.keymap.set('v', '<leader>fg', function()
  local saved_reg = vim.fn.getreg('v')
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', saved_reg)
  text = string.gsub(text, "\n", "")
  require('telescope.builtin').live_grep({ default_text = text })
end, { noremap = true})


vim.cmd[[colorscheme tokyonight-night]]

-----------------------
----- LSP stuff -------
-----------------------

-- Attach keybindings when an LSP server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP keybindings',
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
    vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  end,
})

-- Configure nvim-cmp
local cmp = require('cmp')
cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
  },
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Default capabilities for all LSP servers
vim.lsp.config('*', {
  capabilities = capabilities,
})

require('mason').setup({})
require('mason-lspconfig').setup({})

-- Server specific configurations
vim.lsp.config('clangd', {
  cmd = {
    "clangd",
    "--extra-arg=-std=c++26",
    "--extra-arg=-stdlib=libc++",
  },
})
vim.lsp.enable('clangd')

-- Filetype detection & LSP config for Roc language
vim.filetype.add({
  extension = {
    roc = "roc",
  },
})

vim.lsp.config('roc_ls', {
  cmd = { "roc", "experimental-lsp" },
  filetypes = { "roc" },
})
vim.lsp.enable('roc_ls')
-----------------------
-----------------------
-----------------------
