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

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    XDG_SESSION_TYPE = "wayland";
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

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Inter" ];
    serif = [ "Inter" ];
    monospace = [
      "JetBrainsMono Nerd Font"
      "JetBrains Mono"
    ];
    emoji = [ "Twemoji Color Emoji" ];
  };
}
