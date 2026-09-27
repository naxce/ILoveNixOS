local p = {
  bg = "#110d17",
  bg_alt = "#17121f",
  bg_float = "#1d1726",
  bg_highlight = "#3a2d4f",
  bg_visual = "#2f2540",
  bg_search = "#443559",
  border = "#6a5790",
  comment = "#9c8cb8",
  muted = "#9c8cb8",
  subtle = "#c2b2da",
  fg_dim = "#c7b8de",
  fg = "#d9ccec",
  fg_bright = "#f0eafa",
  white = "#f0eafa",
  black = "#110d17",
  accent = "#8058c0",
  accent2 = "#a987e8",
  error = "#e07aa8",
  ok = "#d9ccec",
}

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "kitten"

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
hi("CursorLineNr", { fg = p.accent2, bold = true })
hi("LineNr", { fg = p.comment })
hi("SignColumn", { bg = p.bg })
hi("ColorColumn", { bg = p.bg_highlight })
hi("VertSplit", { fg = p.border, bg = p.bg })
hi("WinSeparator", { fg = p.border, bg = p.bg })
hi("StatusLine", { fg = p.fg, bg = p.bg_alt })
hi("StatusLineNC", { fg = p.comment, bg = p.bg_alt })
hi("TabLine", { fg = p.muted, bg = p.bg_alt })
hi("TabLineFill", { bg = p.bg_alt })
hi("TabLineSel", { fg = p.black, bg = p.accent, bold = true })
hi("Pmenu", { fg = p.fg, bg = p.bg_float })
hi("PmenuSel", { fg = p.black, bg = p.accent, bold = true })
hi("PmenuSbar", { bg = p.bg_highlight })
hi("PmenuThumb", { bg = p.border })
hi("Visual", { bg = p.bg_visual })
hi("VisualNOS", { bg = p.bg_visual })
hi("Search", { fg = p.black, bg = p.accent, bold = true })
hi("IncSearch", { fg = p.black, bg = p.accent2, bold = true })
hi("CurSearch", { fg = p.black, bg = p.accent2, bold = true })
hi("MatchParen", { fg = p.fg_bright, bold = true, underline = true })
hi("NonText", { fg = p.bg_highlight })
hi("Whitespace", { fg = p.bg_highlight })
hi("SpecialKey", { fg = p.border })
hi("Folded", { fg = p.muted, bg = p.bg_alt, italic = true })
hi("FoldColumn", { fg = p.comment, bg = p.bg })
hi("Title", { fg = p.accent2, bold = true })
hi("Directory", { fg = p.accent2, bold = true })
hi("ModeMsg", { fg = p.fg_bright, bold = true })
hi("MoreMsg", { fg = p.accent2 })
hi("Question", { fg = p.accent2 })
hi("WildMenu", { fg = p.black, bg = p.accent })

hi("DiagnosticError", { fg = p.error, bold = true })
hi("DiagnosticWarn", { fg = p.accent2, bold = true })
hi("DiagnosticInfo", { fg = p.subtle })
hi("DiagnosticHint", { fg = p.comment })
hi("DiagnosticUnderlineError", { undercurl = true, sp = p.error })
hi("DiagnosticUnderlineWarn", { undercurl = true, sp = p.accent2 })
hi("DiagnosticUnderlineInfo", { underline = true, sp = p.subtle })
hi("DiagnosticUnderlineHint", { underline = true, sp = p.comment })
hi("DiagnosticVirtualTextError", { fg = p.error, bg = p.bg_alt })
hi("DiagnosticVirtualTextWarn", { fg = p.accent2, bg = p.bg_alt })
hi("DiagnosticVirtualTextInfo", { fg = p.subtle, bg = p.bg_alt })
hi("DiagnosticVirtualTextHint", { fg = p.comment, bg = p.bg_alt })

hi("DiffAdd", { fg = p.fg_bright, bg = p.bg_highlight })
hi("DiffChange", { fg = p.subtle, bg = p.bg_highlight })
hi("DiffDelete", { fg = p.comment, bg = p.bg_alt })
hi("DiffText", { fg = p.fg_bright, bg = p.bg_search, bold = true })
hi("GitSignsAdd", { fg = p.fg_bright })
hi("GitSignsChange", { fg = p.subtle })
hi("GitSignsDelete", { fg = p.error })

hi("Comment", { fg = p.comment, italic = true })
hi("Constant", { fg = p.accent2 })
hi("String", { fg = p.fg_dim })
hi("Character", { fg = p.fg_dim })
hi("Number", { fg = p.accent2 })
hi("Boolean", { fg = p.accent2, bold = true })
hi("Float", { fg = p.accent2 })
hi("Identifier", { fg = p.fg })
hi("Function", { fg = p.accent2, bold = true })
hi("Statement", { fg = p.accent, bold = true })
hi("Conditional", { fg = p.accent, bold = true })
hi("Repeat", { fg = p.accent, bold = true })
hi("Label", { fg = p.subtle })
hi("Operator", { fg = p.subtle })
hi("Keyword", { fg = p.accent, bold = true })
hi("Exception", { fg = p.error, bold = true })
hi("PreProc", { fg = p.subtle })
hi("Include", { fg = p.subtle, bold = true })
hi("Define", { fg = p.subtle })
hi("Macro", { fg = p.subtle })
hi("Type", { fg = p.accent2 })
hi("StorageClass", { fg = p.subtle })
hi("Structure", { fg = p.accent2 })
hi("Typedef", { fg = p.accent2 })
hi("Special", { fg = p.subtle })
hi("SpecialChar", { fg = p.subtle })
hi("Delimiter", { fg = p.muted })
hi("Underlined", { underline = true })
hi("Ignore", { fg = p.comment })
hi("Error", { fg = p.error, bold = true, underline = true })
hi("Todo", { fg = p.black, bg = p.accent2, bold = true })

hi("@variable", { fg = p.fg })
hi("@variable.builtin", { fg = p.accent2, italic = true })
hi("@variable.parameter", { fg = p.fg_dim })
hi("@property", { fg = p.fg_dim })
hi("@field", { fg = p.fg_dim })
hi("@constructor", { fg = p.accent2 })
hi("@punctuation.bracket", { fg = p.muted })
hi("@punctuation.delimiter", { fg = p.muted })
hi("@tag", { fg = p.accent2, bold = true })
hi("@tag.attribute", { fg = p.subtle, italic = true })
hi("@markup.heading", { fg = p.accent2, bold = true })
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
hi("TelescopeMatching", { fg = p.accent2, bold = true })
hi("TelescopePromptBorder", { fg = p.accent2, bg = p.bg_float })
hi("TelescopeTitle", { fg = p.accent2, bold = true })

hi("WhichKey", { fg = p.accent2, bold = true })
hi("WhichKeyGroup", { fg = p.subtle })
hi("WhichKeyDesc", { fg = p.fg })
hi("WhichKeyFloat", { bg = p.bg_float })
hi("WhichKeyBorder", { fg = p.border, bg = p.bg_float })

hi("IblIndent", { fg = p.bg_highlight })
hi("IblScope", { fg = p.border })

vim.o.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr:hor20-Cursor"
