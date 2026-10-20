hl.on("hyprland.start", function()
    for _, cmd in ipairs({
        "sylvaris",
        "hypridle",
        "gnome-keyring-daemon --start --components=secrets",
        "sh -c 'dbus-update-activation-environment --systemd --all && systemctl --user start hyprland-session.target'",
        [[sh -c 'for i in $(seq 40); do xrandr --output "$(hyprctl monitors -j | jq -r ".[] | select(.model == \"LG ULTRAGEAR\") | .name")" --primary && break; sleep 0.5; done']],
    }) do
        hl.exec_cmd(cmd)
    end
end)
