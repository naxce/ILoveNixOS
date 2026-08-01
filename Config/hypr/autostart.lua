hl.on("hyprland.start", function()
    for _, cmd in ipairs({
        "hyprpolkitagent",
        "waybar",
        "swaync",
        "hypridle",
        "hyprpaper",
        "nm-applet --indicator",
        "blueman-applet",
        "wl-paste --watch cliphist store",
        "gnome-keyring-daemon --start --components=secrets",
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "hyprswitch init --show-title --custom-css ~/.config/hyprswitch/style.css",
    }) do
        hl.exec_cmd(cmd)
    end
end)
