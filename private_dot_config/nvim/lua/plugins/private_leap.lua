return {
  "ggandor/leap.nvim",
  event = "VeryLazy",
  dependencies = {
    "tpope/vim-repeat", -- Optional: enables dot-repeat for leap motions
  },
  config = function()
    local leap = require("leap")

    -- Set default keymaps
    vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
    vim.keymap.set("n", "S", "<Plug>(leap-from-window)")

    -- Optional: Configure leap options
    -- leap.opts.case_sensitive = false
    -- leap.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }
  end,
}
