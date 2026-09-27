hl.on("hyprland.start", function()
    for _, cmd in ipairs({
        "sylvaris",
        "hypridle",
        "gnome-keyring-daemon --start --components=secrets",
        "dbus-update-activation-environment --systemd --all",
    }) do
        hl.exec_cmd(cmd)
    end
end)
