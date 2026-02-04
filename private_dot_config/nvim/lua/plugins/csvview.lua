return {
  "hat0uma/csvview.nvim",
  ---@module "csvview"
  ---@type CsvView.Options
  opts = {
    parser = {
      comments = { "#", "//" },
      delimiter = {
        ft = {
          csv = ",",
          tsv = "\t",
        },
        fallbacks = { ",", "\t", ";", "|", ":", " " },
      },
    },
    view = {
      display_mode = "border",
    },
    keymaps = {
      -- Text objects for selecting fields
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      -- Excel-like navigation
      jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
      jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
      jump_next_row = { "<Enter>", mode = { "n", "v" } },
      jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
  },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
  ft = { "csv", "tsv" },
  config = function(_, opts)
    require("csvview").setup(opts)
    -- Auto-enable csvview for CSV and TSV files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "csv", "tsv" },
      callback = function()
        require("csvview").enable()
      end,
    })
  end,
}
