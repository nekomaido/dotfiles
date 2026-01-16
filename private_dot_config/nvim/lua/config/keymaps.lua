-- General keymaps (non-plugin)
local map = vim.keymap.set

-- Delete single character without copying into register
map("n", "x", '"_x', { desc = "Delete char without yank" })

-- Save file
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Quit (force)
map("n", "<C-q>", "<cmd>q!<cr>", { desc = "Quit without saving" })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Window navigation handled by vim-tmux-navigator (C-hjkl)

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
