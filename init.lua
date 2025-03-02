-- ==================
-- lucy's nvim config
-- ==================

local popup_width = 0.8
local border = "single"
local ollama_host = vim.env.SERVER_ADDR

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`

-- Disable spell checking, but add a toggle keymap to enable.
vim.o.spell = false
vim.o.spelllang = "en_us"
vim.keymap.set("n", "<leader>S", ":set spell!<CR>", { desc = "[S]pell check toggle" })

-- Enable true color support
vim.o.termguicolors = true

-- Window options
vim.o.ead = "ver"
vim.o.ea = false
vim.o.splitright = true
vim.o.splitbelow = true

-- QoL/UX options
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

-- UI
vim.o.number = true
vim.o.signcolumn = "yes"
vim.o.breakindent = true
vim.o.inccommand = "split"
vim.o.list = true
vim.opt.listchars = { tab = "| ", trail = "·", nbsp = "␣", extends = "→", precedes = "←" }
vim.opt.cursorline = true
vim.o.scrolloff = 30

-- [[ Basic Keymaps ]]
-- See `:help vim.keymap`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear highlights on <Esc>
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<CS-H>", "<C-w>H", { desc = "Move window to the far left" })
vim.keymap.set("n", "<CS-L>", "<C-w>L", { desc = "Move window to the far right" })
vim.keymap.set("n", "<CS-J>", "<C-w>J", { desc = "Move window to the far top" })
vim.keymap.set("n", "<CS-K>", "<C-w>K", { desc = "Move window to the far bottom" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Force help windows to the right",
  group = vim.api.nvim_create_augroup("help-win-right", { clear = true }),
  pattern = "*/doc/*",
  callback = function(ev)
    local rtp = vim.o.runtimepath
    local files = vim.fn.globpath(rtp, "doc/*", true, 1)
    if ev.file and vim.list_contains(files, ev.file) then
      vim.cmd.wincmd("L")
      vim.cmd("vert resize " .. math.max(90, math.min(60, math.floor(vim.o.columns * 0.4))))
    end
  end,
})

-- [[ Filetypes ]]
vim.filetype.add({ extension = { frag = "glsl" } })

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt`
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup("plugins", {
  ui = {
    border = border,
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
