-- =========================
-- BASIC SETTINGS
-- =========================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.scrolloff = 8
vim.opt.smartindent = true
vim.opt.wrap = false

-- Set tags
vim.opt.tags = "tags;./tags"

vim.g.mapleader = " "

-- =========================
-- BASIC SYNTAX + COLORS
-- =========================
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")
vim.cmd("colorscheme habamax")

-- =========================
-- RIPGREP INTEGRATION
-- =========================
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

-- =========================
-- LAZY.NVIM BOOTSTRAP
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- =========================
-- PLUGINS
-- =========================
require("lazy").setup({

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },
{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local cmp = require("cmp")

    cmp.setup({
      completion = {
        autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
      },

      mapping = {
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
      },

      sources = {
        { name = "nvim_lsp" },
      },
    })
  end,
},
  -- Tree-sitter (highlight ONLY)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if not ok then return end

      ts.setup({
        ensure_installed = { "c", "cpp", "lua","javascript","typescript" },
        highlight = { enable = true },
      })
    end,
  },
  {
    'nvim-telescope/telescope.nvim', version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    }
  },
  {
  "ludovicchabant/vim-gutentags",
  config = function()
    -- Where tags are stored
    vim.g.gutentags_cache_dir = vim.fn.stdpath("data") .. "/gutentags"

    -- Enable modules
    vim.g.gutentags_modules = { "ctags" }

    -- File types (optional)
    vim.g.gutentags_file_list_command = "rg --files"

    -- Automatically generate tags
    vim.g.gutentags_generate_on_write = 1
    vim.g.gutentags_generate_on_new = 1
    vim.g.gutentags_ctags_exclude = {
       ".git",
       "node_modules",
       "dist",
       "build",
       "__pycache__",
      "*.min.js",
      "*.bundle.js"
    }
  end
},
-- LSP + Mason (minimal)
{
  "williamboman/mason.nvim",
  build = ":MasonUpdate",
  config = function()
    require("mason").setup()
  end,
},

{
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = { "ts_ls" },
      automatic_installation = true,
    })
  end,
},
})
-- =========================
-- LSP (FIX)
-- =========================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config('ts_ls', {
  capabilities=capabilities,
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript" },
})
vim.lsp.enable('ts_ls')

-- =========================
-- KEYMAPS
-- =========================

-- Grep search
vim.keymap.set("n", "<leader>g", ":grep ")

-- Quick save
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- Quit
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- Better navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Clear search highlight
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")

--going back to current directory
vim.keymap.set("n", "<leader>c",":e .<CR>")

-- Telescope keyMaps
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- Ctags keybindings
vim.keymap.set("n", "<leader>t", "<cmd>!ctags -R .<CR>", { desc = "Generate tags manually" })

--lsp key bindings
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    local opts = { noremap = true, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  end,
})
vim.diagnostic.config({
  virtual_text = true,   -- show inline errors
  signs = true,          -- gutter icons
  underline = true,
  update_in_insert = false,
})
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>x", vim.diagnostic.setloclist)
-- =========================
-- PERFORMANCE
-- =========================
vim.opt.updatetime = 200 
vim.opt.timeoutlen = 300
vim.opt.signcolumn = "yes"
