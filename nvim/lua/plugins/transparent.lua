return {
  "xiyaowong/transparent.nvim",
  config = function()
    require("transparent").setup({
      extra_groups = { -- Дополнительные группы для прозрачности
        "Normal",
        "NormalNC",
        "StatusLine",
        "StatusLineNC",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
        "WinSeparator",
      },
      exclude_groups = {}, -- Группы которые НЕ делать прозрачными
    })

    -- Включить прозрачность при запуске
    require("transparent").toggle(true)
  end,
}
