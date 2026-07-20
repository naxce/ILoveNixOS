return {
  {
    "noir-theme",
    dir = vim.fn.stdpath("config"),
    name = "noir",
    lazy = false,
    priority = 1000,
    config = function()
      local p = {
        bg = "#000000",
        bg_alt = "#0a0a0a",
        bg_float = "#111111",
        bg_highlight = "#1a1a1a",
        bg_visual = "#2a2a2a",
        bg_search = "#333333",
        border = "#4d4d4d",
        comment = "#6a6a6a",
        muted = "#8a8a8a",
        subtle = "#b0b0b0",
        fg_dim = "#cfcfcf",
        fg = "#e8e8e8",
        fg_bright = "#ffffff",
        white = "#ffffff",
        black = "#000000",
        error = "#ffffff",
        ok = "#e8e8e8",
      }

      vim.cmd("hi clear")
      if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
      end
      vim.o.termguicolors = true
      vim.o.background = "dark"
      vim.g.colors_name = "noir"

      local hi = function(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
      end

      hi("Normal", { fg = p.fg, bg = p.bg })
      hi("NormalFloat", { fg = p.fg, bg = p.bg_float })
      hi("NormalNC", { fg = p.fg_dim, bg = p.bg })
      hi("FloatBorder", { fg = p.border, bg = p.bg_float })
      hi("FloatTitle", { fg = p.fg_bright, bg = p.bg_float, bold = true })
      hi("Cursor", { fg = p.bg, bg = p.fg_bright })
      hi("CursorLine", { bg = p.bg_highlight })
      hi("CursorLineNr", { fg = p.fg_bright, bold = true })
      hi("LineNr", { fg = p.comment })
      hi("SignColumn", { bg = p.bg })
      hi("ColorColumn", { bg = p.bg_highlight })
      hi("VertSplit", { fg = p.border, bg = p.bg })
      hi("WinSeparator", { fg = p.border, bg = p.bg })
      hi("StatusLine", { fg = p.fg, bg = p.bg_alt })
      hi("StatusLineNC", { fg = p.comment, bg = p.bg_alt })
      hi("TabLine", { fg = p.muted, bg = p.bg_alt })
      hi("TabLineFill", { bg = p.bg_alt })
      hi("TabLineSel", { fg = p.black, bg = p.fg_bright, bold = true })
      hi("Pmenu", { fg = p.fg, bg = p.bg_float })
      hi("PmenuSel", { fg = p.black, bg = p.fg_bright, bold = true })
      hi("PmenuSbar", { bg = p.bg_highlight })
      hi("PmenuThumb", { bg = p.border })
      hi("Visual", { bg = p.bg_visual })
      hi("VisualNOS", { bg = p.bg_visual })
      hi("Search", { fg = p.black, bg = p.fg_bright, bold = true })
      hi("IncSearch", { fg = p.black, bg = p.fg_bright, bold = true })
      hi("CurSearch", { fg = p.black, bg = p.fg_bright, bold = true })
      hi("MatchParen", { fg = p.fg_bright, bold = true, underline = true })
      hi("NonText", { fg = p.bg_highlight })
      hi("Whitespace", { fg = p.bg_highlight })
      hi("SpecialKey", { fg = p.border })
      hi("Folded", { fg = p.muted, bg = p.bg_alt, italic = true })
      hi("FoldColumn", { fg = p.comment, bg = p.bg })
      hi("Title", { fg = p.fg_bright, bold = true })
      hi("Directory", { fg = p.fg_bright, bold = true })
      hi("ModeMsg", { fg = p.fg_bright, bold = true })
      hi("MoreMsg", { fg = p.fg_bright })
      hi("Question", { fg = p.fg_bright })
      hi("WildMenu", { fg = p.black, bg = p.fg_bright })

      hi("DiagnosticError", { fg = p.fg_bright, bold = true })
      hi("DiagnosticWarn", { fg = p.subtle, bold = true })
      hi("DiagnosticInfo", { fg = p.muted })
      hi("DiagnosticHint", { fg = p.comment })
      hi("DiagnosticUnderlineError", { undercurl = true, sp = p.fg_bright })
      hi("DiagnosticUnderlineWarn", { undercurl = true, sp = p.subtle })
      hi("DiagnosticUnderlineInfo", { underline = true, sp = p.muted })
      hi("DiagnosticUnderlineHint", { underline = true, sp = p.comment })
      hi("DiagnosticVirtualTextError", { fg = p.fg_bright, bg = p.bg_alt })
      hi("DiagnosticVirtualTextWarn", { fg = p.subtle, bg = p.bg_alt })
      hi("DiagnosticVirtualTextInfo", { fg = p.muted, bg = p.bg_alt })
      hi("DiagnosticVirtualTextHint", { fg = p.comment, bg = p.bg_alt })

      hi("DiffAdd", { fg = p.fg_bright, bg = p.bg_highlight })
      hi("DiffChange", { fg = p.subtle, bg = p.bg_highlight })
      hi("DiffDelete", { fg = p.comment, bg = p.bg_alt })
      hi("DiffText", { fg = p.fg_bright, bg = p.bg_search, bold = true })
      hi("GitSignsAdd", { fg = p.fg_bright })
      hi("GitSignsChange", { fg = p.subtle })
      hi("GitSignsDelete", { fg = p.comment })

      hi("Comment", { fg = p.comment, italic = true })
      hi("Constant", { fg = p.fg_bright })
      hi("String", { fg = p.fg_dim })
      hi("Character", { fg = p.fg_dim })
      hi("Number", { fg = p.fg_bright })
      hi("Boolean", { fg = p.fg_bright, bold = true })
      hi("Float", { fg = p.fg_bright })
      hi("Identifier", { fg = p.fg })
      hi("Function", { fg = p.fg_bright, bold = true })
      hi("Statement", { fg = p.fg_bright, bold = true })
      hi("Conditional", { fg = p.fg_bright, bold = true })
      hi("Repeat", { fg = p.fg_bright, bold = true })
      hi("Label", { fg = p.subtle })
      hi("Operator", { fg = p.subtle })
      hi("Keyword", { fg = p.fg_bright, bold = true })
      hi("Exception", { fg = p.fg_bright, bold = true })
      hi("PreProc", { fg = p.subtle })
      hi("Include", { fg = p.subtle, bold = true })
      hi("Define", { fg = p.subtle })
      hi("Macro", { fg = p.subtle })
      hi("Type", { fg = p.fg_bright })
      hi("StorageClass", { fg = p.subtle })
      hi("Structure", { fg = p.fg_bright })
      hi("Typedef", { fg = p.fg_bright })
      hi("Special", { fg = p.subtle })
      hi("SpecialChar", { fg = p.subtle })
      hi("Delimiter", { fg = p.muted })
      hi("Underlined", { underline = true })
      hi("Ignore", { fg = p.comment })
      hi("Error", { fg = p.fg_bright, bold = true, underline = true })
      hi("Todo", { fg = p.black, bg = p.fg_bright, bold = true })

      hi("@variable", { fg = p.fg })
      hi("@variable.builtin", { fg = p.fg_bright, italic = true })
      hi("@variable.parameter", { fg = p.fg_dim })
      hi("@property", { fg = p.fg_dim })
      hi("@field", { fg = p.fg_dim })
      hi("@constructor", { fg = p.fg_bright })
      hi("@punctuation.bracket", { fg = p.muted })
      hi("@punctuation.delimiter", { fg = p.muted })
      hi("@tag", { fg = p.fg_bright, bold = true })
      hi("@tag.attribute", { fg = p.subtle, italic = true })
      hi("@markup.heading", { fg = p.fg_bright, bold = true })
      hi("@markup.link", { fg = p.fg_dim, underline = true })
      hi("@markup.raw", { fg = p.fg_dim })

      hi("LspReferenceText", { bg = p.bg_highlight })
      hi("LspReferenceRead", { bg = p.bg_highlight })
      hi("LspReferenceWrite", { bg = p.bg_search })
      hi("LspInlayHint", { fg = p.comment, bg = p.bg_alt, italic = true })
      hi("LspCodeLens", { fg = p.comment, italic = true })

      hi("TelescopeBorder", { fg = p.border, bg = p.bg_float })
      hi("TelescopeNormal", { fg = p.fg, bg = p.bg_float })
      hi("TelescopeSelection", { fg = p.fg_bright, bg = p.bg_highlight, bold = true })
      hi("TelescopeMatching", { fg = p.fg_bright, bold = true })
      hi("TelescopePromptBorder", { fg = p.fg_bright, bg = p.bg_float })
      hi("TelescopeTitle", { fg = p.fg_bright, bold = true })

      hi("WhichKey", { fg = p.fg_bright, bold = true })
      hi("WhichKeyGroup", { fg = p.subtle })
      hi("WhichKeyDesc", { fg = p.fg })
      hi("WhichKeyFloat", { bg = p.bg_float })
      hi("WhichKeyBorder", { fg = p.border, bg = p.bg_float })

      hi("IblIndent", { fg = p.bg_highlight })
      hi("IblScope", { fg = p.border })

      vim.o.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr:hor20-Cursor"
    end,
  },
}
