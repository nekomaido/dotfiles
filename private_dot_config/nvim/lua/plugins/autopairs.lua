return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true, -- use treesitter
    disable_filetype = { "TelescopePrompt", "vim" },
  },
}
