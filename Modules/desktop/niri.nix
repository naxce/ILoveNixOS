{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    swaybg

    (pkgs.writeShellScriptBin "niri-waybar" ''
      exec ${pkgs.waybar}/bin/waybar \
        --config "$HOME/.config/waybar/config-niri.jsonc" \
        --style "$HOME/.config/waybar/style.css"
    '')

    (lib.hiPrio (pkgs.writeShellScriptBin "niri" ''
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

      exec ${config.programs.niri.package}/bin/niri --session "$@"
    ''))

    (pkgs.runCommand "niri-cli" { } ''
      mkdir -p $out/bin
      ln -s ${config.programs.niri.package}/bin/niri $out/bin/niri-cli
    '')
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security.pam.services.swaylock = { };
}
