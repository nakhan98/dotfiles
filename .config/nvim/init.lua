-- Neovim-only config.
-- See ~/.vimrc for lean Vim config.

-- ============================================================================
-- Bootstrap lazy.nvim
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- FZF runtime path (required by fzf.vim)
if vim.fn.has("mac") == 1 then
  vim.opt.rtp:append("/opt/homebrew/opt/fzf")
else
  vim.opt.rtp:append(vim.fn.expand("~/.fzf"))
end

-- ============================================================================
-- Options
-- ============================================================================
local opt = vim.opt

opt.number        = true          -- line numbers
opt.tabstop       = 4
opt.shiftwidth    = 4
opt.expandtab     = true          -- expand tabs to spaces
opt.ignorecase    = true          -- case-insensitive search
opt.hlsearch      = true          -- highlight search results
opt.linebreak     = true          -- wrap at word boundaries
opt.colorcolumn   = "80"
opt.background    = "dark"
opt.termguicolors = true
opt.mouse         = "a"
opt.clipboard     = "unnamedplus" -- system clipboard
opt.backup        = true
opt.modelines     = 0
opt.modeline      = false
opt.equalalways   = false          -- prevent splits auto-resizing on close
opt.laststatus    = 2
opt.showtabline   = 2

-- Ripgrep
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --color=never --vimgrep"
  vim.api.nvim_create_user_command("Rgpy", function(args)
    vim.cmd("cexpr system('rg --vimgrep -tpy " .. args.args .. "') | cw")
  end, { nargs = 1 })
  vim.api.nvim_create_user_command("Rgc", function(args)
    vim.cmd("cexpr system('rg --vimgrep " .. args.args .. "') | cw")
  end, { nargs = "*" })
end

-- ============================================================================
-- Keymaps
-- ============================================================================
local map = vim.keymap.set

-- Pane navigation
map("n", "<C-J>", "<C-W><C-J>")
map("n", "<C-K>", "<C-W><C-K>")
map("n", "<C-L>", "<C-W><C-L>")
map("n", "<C-H>", "<C-W><C-H>")

-- FZF
map("n", "<C-p>", ":Files<CR>", { silent = true })

-- ============================================================================
-- Autocommands
-- ============================================================================
-- YAML indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.opt_local.tabstop     = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth  = 2
    vim.opt_local.expandtab   = true
  end,
})

-- ============================================================================
-- Plugins
-- ============================================================================
require("lazy").setup({

  -- --------------------------------------------------------------------------
  -- Colorscheme
  -- --------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy     = false,
    priority = 1000,
    config   = function()
      vim.cmd("colorscheme tokyonight")
    end,
  },

  -- --------------------------------------------------------------------------
  -- Statusline + bufferline (replaces lightline + lightline-bufferline)
  -- --------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight" },
        tabline = {
          lualine_a = { "buffers" },
          lualine_z = { "tabs" },
        },
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- File explorer (replaces NERDTree)
  -- --------------------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        filters = { dotfiles = false },
      })
      -- Open on startup and move cursor to main window
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          require("nvim-tree.api").tree.open()
          vim.cmd("wincmd p")
        end,
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Indent guides (replaces indentLine)
  -- --------------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main   = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- --------------------------------------------------------------------------
  -- Treesitter — syntax highlighting + indentation
  -- (replaces hynek/vim-python-pep8-indent for Python)
  -- --------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "lua", "bash", "yaml", "json", "markdown" },
        highlight        = { enable = true },
        indent           = { enable = true },
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- LSP (replaces jedi-vim)
  -- Requires: pip install pyright  OR  npm install -g pyright
  -- --------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").pyright.setup({})
    end,
  },

  -- --------------------------------------------------------------------------
  -- Formatting (replaces python/black plugin)
  -- Requires: pip install black
  -- Uncomment format_on_save to auto-format on write.
  -- --------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "black" },
        },
        -- format_on_save = { timeout_ms = 500, lsp_fallback = true },
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Linting (replaces vim-flake8)
  -- Requires: pip install flake8  (or ruff — swap below)
  -- --------------------------------------------------------------------------
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("lint").linters_by_ft = {
        python = { "flake8" }, -- swap for "ruff" if preferred
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Markdown rendering
  -- --------------------------------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("render-markdown").setup({})
    end,
  },

  -- --------------------------------------------------------------------------
  -- FZF
  -- --------------------------------------------------------------------------
  { "junegunn/fzf.vim" },

  -- --------------------------------------------------------------------------
  -- Commenting
  -- Note: Neovim 0.10+ has `gc` built-in — this plugin can be removed if
  -- you are on 0.10+.
  -- --------------------------------------------------------------------------
  { "tpope/vim-commentary" },

  -- --------------------------------------------------------------------------
  -- Tmux clipboard integration
  -- --------------------------------------------------------------------------
  { "roxma/vim-tmux-clipboard" },

}, {
  checker = { enabled = false }, -- disable automatic update checks
})
