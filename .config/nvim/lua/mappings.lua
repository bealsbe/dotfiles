require "nvchad.mappings"
local map = vim.keymap.set
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Copy with Ctrl+C in visual mode
map("v", "<C-c>", '"+y', opts)

-- Paste with Ctrl+V in insert mode
map("i", "<C-v>", '<C-r>+', opts)

-- Paste with Ctrl+V in normal mode
map("n", "<C-v>", '"+p', opts)

-- Paste with Ctrl+V in visual mode (replace selection)
map("v", "<C-v>", '"+p', opts)

-- Optional: Copy the entire line in normal mode with Ctrl+C
map("n", "<C-c>", '"+yy', opts)

--Cut with Ctrl+X in visual mode
map("v", "<C-x>", '"+d', opts)
--
-- -- Cut with Ctrl+X in normal mode (cut current line)
map("n", "<C-x>", '"+dd', opts)
