{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.greetd.enable = false;
  services.xserver.enable = false;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  /*
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "start-hyprland" ''
        # Refuse to nest sessions or run outside a real TTY.
        if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
          echo "start-hyprland: a graphical session is already running" >&2
          exit 1
        fi

        exec ${pkgs.hyprland}/bin/Hyprland
      '')
    ];
  */

  programs.zsh.shellAliases = {
    hl = "start-hyprland";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    XDG_DATA_DIRS = [
      "/var/lib/flatpak/exports/share"
      "$HOME/.local/share/flatpak/exports/share"
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];

    config = {
      hyprland.default = "hyprland";
      plasma.default = "kde";
    };
  };

  environment.variables.BALOO_ENABLED = "0";

  services.printing.enable = false;
  services.avahi.enable = false;

  boot.blacklistedKernelModules = [
    "pcspkr"
    "snd_pcsp"
    "nouveau"
  ];

  security.pam.services.hyprlock = { };

  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  fonts.fontconfig.defaultFonts.emoji = [ "Twemoji Color Emoji" ];
}
