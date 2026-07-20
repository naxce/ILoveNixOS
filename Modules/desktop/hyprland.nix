{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./nixgreet.nix ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
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
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "hyprland";
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
