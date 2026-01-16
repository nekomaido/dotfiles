return {
  "echasnovski/mini.nvim",
  version = false,
  event = "VeryLazy",
  config = function()
    -- require("mini.pairs").setup() -- Disabled: using nvim-autopairs instead
    require("mini.comment").setup()  -- gcc to comment
    require("mini.surround").setup() -- sa/sd/sr for surround
    require("mini.icons").setup()    -- Icons
  end,
}
