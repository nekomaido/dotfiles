return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    require("telescope").setup({
      pickers = {
        find_files = {
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })
    require("telescope").load_extension("fzf")
    local builtin = require("telescope.builtin")
    local function get_cwd()
      return vim.uv.cwd() or vim.fn.getcwd() or vim.fn.expand("%:p:h")
    end
    local function safe_find_files()
      builtin.find_files({ cwd = get_cwd() })
    end
    local function safe_live_grep()
      builtin.live_grep({ cwd = get_cwd() })
    end
    vim.keymap.set("n", "<leader>ff", safe_find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", safe_live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
  end,
}
