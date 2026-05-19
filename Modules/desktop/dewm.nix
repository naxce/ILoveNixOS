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
  environment.variables.BALOO_ENABLED = "0";

  # Klawiatura ekranowa
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      qt6Packages.fcitx5-configtool
    ];
  };

  environment.sessionVariables = {
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };

  # KDE Plasma Debloat
  services.printing.enable = false;
  services.avahi.enable = false;

  boot.blacklistedKernelModules = [
    "pcspkr"
    "snd_pcsp"
    "nouveau"
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen
    khelpcenter
    konsole
    elisa
    okular
    kate
    kmail
    kontact
    korganizer
    kaddressbook
    akregator
    kwalletmanager
    plasma-thunderbolt
    discover
    kde-inotify-survey
    kdeconnect-kde
    baloo
    krdp
    kdnssd
    print-manager
    kweather
  ];
}
