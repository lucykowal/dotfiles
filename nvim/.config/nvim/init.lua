-- ==================
-- lucy's nvim config
-- ==================

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- see `:help vim.opt`

-- disable spell checking, but add a toggle keymap to enable.
vim.o.spell = false
vim.o.spelllang = "en_us"
vim.keymap.set("n", "<leader>S", ":set spell!<CR>", { desc = "[S]pell check toggle" })

-- enable true color support
vim.o.termguicolors = true

-- window options
vim.o.ead = "both"
vim.o.ea = true
vim.o.splitright = true
vim.o.splitbelow = true

-- qol/ux options
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300 -- for mapped sequences
vim.o.updatetime = 250
vim.o.undofile = true
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- ui options. see `:help <option name>`
vim.o.number = true
vim.o.signcolumn = "yes"
vim.o.breakindent = true
vim.o.inccommand = "split"
vim.o.list = true
vim.opt.listchars = { tab = "| ", trail = "·", nbsp = "␣", extends = "→", precedes = "←" }
vim.opt.cursorline = true
vim.o.scrolloff = 30
vim.o.shortmess = "ltToOCFI"

vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
  callback = function()
    vim.o.gcr =
      "n-v-c-sm:block,i-ci-ve:ver25-blinkon10-blinkoff10-blinkwait5,r-cr-o:hor20-blinkon3-blinkoff1-blinkwait0"
  end,
})
vim.api.nvim_create_autocmd({ "VimLeave", "VimSuspend" }, {
  callback = function()
    vim.o.gcr = "a:block-blinkon10-blinkoff10"
  end,
})

vim.diagnostic.config({ virtual_text = { virt_text_pos = "eol" } })

-- keymaps
-- see `:help vim.keymap`
vim.keymap.set("n", "<leader>dd", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle [D]iagnostics [D]" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-s>", "<C-w>s", { desc = "Split window" })
vim.keymap.set("n", "<C-v>", "<C-w>v", { desc = "Vertically split window" })

-- autocommands
-- see `:help lua-guide-autocommands`
vim.api.nvim_create_autocmd("TextYankPost", { -- yank highlight
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- filetypes
vim.filetype.add({ extension = { frag = "glsl" } })
vim.filetype.add({ extension = { sc = "supercollider" } })
vim.filetype.add({ extension = { txt = "text" } })

-- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  lazy = true,
  ui = {
    border = require("settings").window.border,
    backdrop = 100,
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {},
  },
  dev = {
    path = "~/Documents/code/lua/nvim",
    fallback = true,
  },
  change_detection = {
    enabled = false,
  },
  defaults = {
    version = "*",
  },
})
