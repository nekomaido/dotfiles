-- nvim-web-devicons must load EARLY (not lazy) for icons to work
return {
  "nvim-tree/nvim-web-devicons",
  lazy = false,
  priority = 1000,
  config = function()
    require("nvim-web-devicons").setup({
      default = true,
      strict = true,
      color_icons = true,
    })
  end,
}
