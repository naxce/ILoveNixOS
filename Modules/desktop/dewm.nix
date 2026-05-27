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

  # KDE Connect
  programs.kdeconnect.enable = true;

  # KDE Plasma Debloat
  # WARNING: CHECK IF YOU DO NOT USE THESE KDE PACKAGES
  services.printing.enable = false;
  services.avahi.enable = false;

  boot.blacklistedKernelModules = [
    "pcspkr"
    "snd_pcsp"
    "nouveau"
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen
    oxygen-icons
    oxygen-sounds
    kdenlive
    khelpcenter
    konsole
    elisa
    okular
    kate
    yakuake
    kmail
    kmail-account-wizard
    kontact
    korganizer
    kaddressbook
    akregator
    akonadi
    akonadi-calendar
    akonadi-calendar-tools
    akonadi-contacts
    akonadi-import-wizard
    akonadi-mime
    akonadi-search
    akonadiconsole
    kdepim-addons
    kdepim-runtime
    grantlee-editor
    grantleetheme
    pim-data-exporter
    pim-sieve-editor
    ktnef
    ksmtp
    kwallet
    kwallet-pam
    kwalletmanager
    plasma-thunderbolt
    plasma-firewall
    plasma-vault
    discover
    kde-inotify-survey
    baloo
    baloo-widgets
    krdp
    kdnssd
    print-manager
    plasma-systemmonitor
    kweather
    kweathercore
    qrca
    skanlite
    skanpage
    plasma-welcome
    sweeper
    ksystemlog
  ];
}
