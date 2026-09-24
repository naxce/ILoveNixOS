hl.on("hyprland.start", function()
    for _, cmd in ipairs({
        "hyprpolkitagent",
        "sylvaris",
        "hypridle",
        "hyprpaper",
        "nm-applet --indicator",
        "blueman-applet",
        "wl-paste --watch cliphist store",
        "gnome-keyring-daemon --start --components=secrets",
        "dbus-update-activation-environment --systemd --all",
        "hyprswitch init --show-title --custom-css ~/.config/hyprswitch/style.css",
    }) do
        hl.exec_cmd(cmd)
    end
end)
