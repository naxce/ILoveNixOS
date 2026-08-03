require("monitors")
require("input")
require("looknfeel")
require("binds")
require("windowrules")
require("autostart")

for _, override in ipairs({
    "local.monitors",
    "local.looknfeel",
    "local.input",
    "local.gaming",
}) do
    pcall(require, override)
end

exec_once("systemctl --user start hyprpolkitagent")

hl.env("XCURSOR_SIZE", "20")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")

hl.env("GTK_THEME", "adw-gtk3-dark")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
