return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local opts = { buffer = bufnr }
      vim.keymap.set("n", "]c", gs.next_hunk, opts)
      vim.keymap.set("n", "[c", gs.prev_hunk, opts)
      vim.keymap.set("n", "<leader>hs", gs.stage_hunk, opts)
      vim.keymap.set("n", "<leader>hr", gs.reset_hunk, opts)
      vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts)
      vim.keymap.set("n", "<leader>hb", gs.blame_line, opts)
    end,
  },
}
