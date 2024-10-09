------------------------------------------------------------------------------
-- GLOBAL
------------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.wo.fillchars = 'eob: '

------------------------------------------------------------------------------
--  OPTIONS
--  See `:help vim.opt`
--  For more options, you can see `:help option-list`
------------------------------------------------------------------------------

vim.opt.number = true -- Enable line numbers
vim.opt.relativenumber = true -- Lines are relative (helps with jumping)
vim.opt.mouse = 'a' -- Enable the mouse
vim.opt.showmode = false -- Do not show mode (already in the statusline)
vim.opt.clipboard = 'unnamedplus' -- Vim <-> OS Clipboard
vim.opt.breakindent = true
vim.opt.undofile = true -- Undo history
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = {
  tab = '» ',
  trail = '·',
  nbsp = '␣'
}
vim.opt.inccommand = 'split' -- Preview substitutions
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.o.termguicolors = true

------------------------------------------------------------------------------
-- KEYMAPS
--  See `:help vim.keymap.set()`
------------------------------------------------------------------------------

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

------------------------------------------------------------------------------
-- INSTALL LAZY.NVIM
------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo(
      {{"Failed to clone lazy.nvim:\n", "ErrorMsg"}, {out, "WarningMsg"}, {"\nPress any key to exit..."}}, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------------------------
-- SET UP PLUGINS
------------------------------------------------------------------------------

require('lazy').setup({{ -- Syntax Highlighting / Simple Code Completion
  "nvim-treesitter/nvim-treesitter",
  config = function()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = {"c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "bash", "tmux"},
      auto_install = true,
      highlight = {
        enable = true
      }
    }
  end
}, {
  "Mofiqul/adwaita.nvim",
  priority = 1000,
  config = function()
    vim.g.adwaita_transparent = true
    vim.cmd.colorscheme "adwaita"
  end
}})
