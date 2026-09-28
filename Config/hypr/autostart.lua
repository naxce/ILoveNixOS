hl.on("hyprland.start", function()
    for _, cmd in ipairs({
        "sylvaris",
        "hypridle",
        "gnome-keyring-daemon --start --components=secrets",
        "dbus-update-activation-environment --systemd --all",
        "sh -c 'for i in $(seq 40); do xrandr --output DP-6 --primary && break; sleep 0.5; done'",
    }) do
        hl.exec_cmd(cmd)
    end
end)
