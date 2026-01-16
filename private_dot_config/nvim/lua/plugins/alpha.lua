return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      [[                                                    ]],
      [[  ███╗   ██╗███████╗██╗  ██╗ ██████╗ ███╗   ███╗ █████╗ ██╗██████╗  ██████╗  ]],
      [[  ████╗  ██║██╔════╝██║ ██╔╝██╔═══██╗████╗ ████║██╔══██╗██║██╔══██╗██╔═══██╗ ]],
      [[  ██╔██╗ ██║█████╗  █████╔╝ ██║   ██║██╔████╔██║███████║██║██║  ██║██║   ██║ ]],
      [[  ██║╚██╗██║██╔══╝  ██╔═██╗ ██║   ██║██║╚██╔╝██║██╔══██║██║██║  ██║██║   ██║ ]],
      [[  ██║ ╚████║███████╗██║  ██╗╚██████╔╝██║ ╚═╝ ██║██║  ██║██║██████╔╝╚██████╔╝ ]],
      [[  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝  ]],
      [[                                                    ]],
    }

    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#FFFFFF" })
    dashboard.section.header.opts.hl = "AlphaHeader"

    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
      dashboard.button("n", "  New file", ":ene <BAR> startinsert<CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
      dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
      dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    }

    dashboard.section.footer.val = "Neovim loaded"

    alpha.setup(dashboard.config)
  end,
}
