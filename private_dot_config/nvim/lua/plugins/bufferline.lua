return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
    { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close unpinned" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
    { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to right" },
    { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers to left" },
    { "<leader>bc", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    { "<leader>bx", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
    { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete buffer" },
  },
  opts = {
    options = {
      mode = "buffers",
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(_, _, diag)
        local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")
        return vim.trim(ret)
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Explorer",
          highlight = "Directory",
          separator = true,
        },
      },
      show_buffer_close_icons = true,
      show_close_icon = false,
      separator_style = "thin",
      always_show_bufferline = true,
    },
  },
}
