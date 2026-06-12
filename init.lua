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

    {'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'},
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},
    {'sindrets/diffview.nvim'}, 
    {'nvim-treesitter/nvim-treesitter', branch = 'master', lazy = false, build = ":TSUpdate"},
    {
      'neovim/nvim-lspconfig',
      lazy = false,
      dependencies = {
        -- main one
        { "ms-jpq/coq_nvim", branch = "coq" },

        -- 9000+ Snippets
        { "ms-jpq/coq.artifacts", branch = "artifacts" },

        -- lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
        -- Need to **configure separately**
        { 'ms-jpq/coq.thirdparty', branch = "3p" }
        -- - shell repl
        -- - nvim lua api
        -- - scientific calculator
        -- - comment banner
        -- - etc
      },
      init = function()
        vim.g.coq_settings = {
          auto_start = "shut-up", -- if you want to start COQ at startup
          -- Your COQ settings here
        }
      end,
      config = function()
        -- Your LSP settings here
      end,
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
      'huggingface/llm.nvim',
      opts = {
        backend = "ollama",
        model = "gemma3:1b-it-qat",
        url = "http://127.0.0.1:11434",
        enable_suggestions_on_startup = false,
      }
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
vim.api.nvim_del_keymap('n', '<Tab>')
vim.keymap.set('n', 'j', "gj", { noremap = true })
vim.keymap.set('n', 'k', "gk", { noremap = true })
vim.keymap.set('v', 'p', '"_dP', { noremap = true })
vim.keymap.set('v', '<S-j>', ":m '>+1<cr>gv=gv", { noremap = true })
vim.keymap.set('v', '<S-k>', ":m '<-2<cr>gv=gv", { noremap = true })
vim.keymap.set('t', '<Esc><Esc>', "<C-\\><C-n>", { noremap = true })
vim.keymap.set('n', '<leader>tt', ":botright split | term<cr>", { noremap = true })
vim.keymap.set('n', '<leader>gg', ":botright vsplit | vertical resize 100 | term<cr>gemini<cr>", { noremap = true })
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
local lsp_zero = require('lsp-zero')

-- lsp_attach is where you enable features that only work
-- if there is a language server active in the file
local lsp_attach = function(client, bufnr)
  local opts = {buffer = bufnr}

  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
  vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
  vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  vim.keymap.set('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float(0, {scope="line"})<cr>', opts)
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      if server_name == "clangd" then
        require('lspconfig').clangd.setup({
          init_options = {
            compileCommands = {
              Add = {
                "-std=c++26 -stdlib=libc++",
              },
              Remove = {},
            },
          },
        })
      else
        require('lspconfig')[server_name].setup({})
      end
    end,
  },
})
-----------------------
-----------------------
-----------------------
