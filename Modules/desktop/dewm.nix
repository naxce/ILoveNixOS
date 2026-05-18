{ config, pkgs, ... }:

{
  # X11
  services.xserver.enable = true;

  # SDDM + Wayland
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # KDE
  services.desktopManager.plasma6.enable = true;

  # KDE Debloat
  services.baloo.enable = false;
  services.akonadi.enable = false;
  programs.kdeconnect.enable = false;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    dolphin
    gwenview
    okular
    kate
    spectacle
    khelpcenter
    elisa
  ];
}
