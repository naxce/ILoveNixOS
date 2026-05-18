{ config, pkgs, ... }:
{
  # X11
  services.xserver.enable = true;

  # SDDM + Wayland
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # KDE Plasma Debloat
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen
    khelpcenter
    konsole
    elisa
    gwenview
    okular
    kate
    ark
    kmail
    kontact
    korganizer
    kaddressbook
    akregator
    dragonplayer
    kwalletmanager
    kdeconnect-kde
    baloo
    krdp
    kdnssd
    print-manager
    kcalc
    spectacle
  ];
}
