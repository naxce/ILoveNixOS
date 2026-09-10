{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.sway = {
    enable = true;
    package = null;
    xwayland.enable = true;
    wrapperFeatures.gtk = true;
  };

  environment.systemPackages = with pkgs; [
    swaylock
    swayidle
    swaybg

    (pkgs.runCommand "sway-companion-tools" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.sway-unwrapped}/bin/swaymsg $out/bin/swaymsg
      ln -s ${pkgs.sway-unwrapped}/bin/swaynag $out/bin/swaynag
      ln -s ${pkgs.sway-unwrapped}/bin/swaybar $out/bin/swaybar
    '')

    (pkgs.writeShellScriptBin "sway-waybar" ''
      exec ${pkgs.waybar}/bin/waybar \
        --config "$HOME/.config/waybar/config-sway.jsonc" \
        --style "$HOME/.config/waybar/style.css"
    '')

    (pkgs.writeShellScriptBin "sway" ''
      if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
        echo "sway: a graphical session is already running" >&2
        exit 1
      fi

      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_DESKTOP=sway
      export LIBVA_DRIVER_NAME=nvidia
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export WLR_NO_HARDWARE_CURSORS=1
      export SWAY_UNSUPPORTED_GPU=1

      exec ${pkgs.sway-unwrapped}/bin/sway "$@"
    '')
  ];

  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-wlr
    pkgs.xdg-desktop-portal-gtk
  ];

  xdg.portal.config.sway.default = lib.mkForce "wlr";

  security.pam.services.swaylock = { };
}
