{
  config,
  pkgs,
  lib,
  ...
}:
{
  # programs.sway pulls in the session/pam/portal/security wrapper plumbing
  # (setuid wrapper for a couple of syscalls, /etc/sway/config seed, etc.)
  # without putting its own "sway" binary ahead of ours on PATH, since we
  # ship a same-named replacement below via environment.systemPackages.
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
    xorg.xrandr

    (pkgs.writeShellScriptBin "sway" ''
      # Refuse to nest sessions or run outside a real TTY.
      if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
        echo "sway: a graphical session is already running" >&2
        exit 1
      fi

      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_DESKTOP=sway
      export LIBVA_DRIVER_NAME=nvidia
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export WLR_NO_HARDWARE_CURSORS=1
      # sway/wlroots on NVIDIA needs the proprietary EGL/GBM path explicitly.
      export WLR_RENDERER=gles2
      export WLR_DRM_NO_ATOMIC=1

      exec ${pkgs.sway-unwrapped}/bin/sway "$@"
    '')
  ];

  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-wlr
    pkgs.xdg-desktop-portal-gtk
  ];

  xdg.portal.config.sway.default = lib.mkForce "wlr";

  security.pam.services.swaylock = { };

  programs.zsh.shellAliases = {
    sw = "sway";
  };
}
