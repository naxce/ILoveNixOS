{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Third compositor alongside Hyprland and Sway. Nothing here touches either
  # of them; you pick one at the TTY.
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    # Wallpaper daemon for niri. hyprpaper is driven over Hyprland's own IPC,
    # so it has nothing to talk to here; swaybg is the portable equivalent and
    # is already pulled in by the Sway module.
    swaybg

    (pkgs.writeShellScriptBin "niri-waybar" ''
      exec ${pkgs.waybar}/bin/waybar \
        --config "$HOME/.config/waybar/config-niri.jsonc" \
        --style "$HOME/.config/waybar/style.css"
    '')

    # Launch niri from a TTY the same way `sway` and `start-hyprland` work.
    #
    # hiPrio because programs.niri.enable puts the upstream `niri` on PATH too;
    # without an explicit priority which one wins is an undefined tiebreak.
    (lib.hiPrio (pkgs.writeShellScriptBin "niri" ''
      # Subcommands have to reach the real binary untouched, or `niri msg`
      # would turn into `niri --session msg` and break.
      case "''${1:-}" in
      msg | validate | completions | panic | help | -h | --help | -V | --version)
        exec ${config.programs.niri.package}/bin/niri "$@"
        ;;
      esac

      if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
        echo "niri: a graphical session is already running" >&2
        echo "      run 'niri msg ...' to talk to it instead" >&2
        exit 1
      fi

      export XDG_CURRENT_DESKTOP=niri
      export XDG_SESSION_DESKTOP=niri
      export XDG_SESSION_TYPE=wayland
      export LIBVA_DRIVER_NAME=nvidia
      export __GLX_VENDOR_LIBRARY_NAME=nvidia

      # --session imports the environment into systemd and D-Bus, which is what
      # makes portals, the keyring and the tray work. It is correct here
      # because this is the main compositor instance, not a nested window.
      exec ${config.programs.niri.package}/bin/niri --session "$@"
    ''))

    # The unwrapped binary under a second name, so scripts never have to care
    # about the launcher's argument handling.
    (pkgs.runCommand "niri-cli" { } ''
      mkdir -p $out/bin
      ln -s ${config.programs.niri.package}/bin/niri $out/bin/niri-cli
    '')
  ];

  # niri ships its own portal preferences; the GTK portal covers file pickers
  # and the like, exactly as it does for the other two compositors.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security.pam.services.swaylock = { };
}
