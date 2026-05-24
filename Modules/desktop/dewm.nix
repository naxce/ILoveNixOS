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
    kdenlive
    plasma-systemmonitor
    kwallet
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
    baloo
    krdp
    kdnssd
    print-manager
    kweather
    vpnimport
    knighttimed
    secretprompter
    qrca
    qrca.wifi
    plasma-systemmonitor
    akonadi.configdialog
    akonadi_contacts_resource
    akonadi_davgroupware_resource
    akonadi_ews_resource
    akonadi_google_resource
    akonadi_imap_resource
    akonadi_kolab_resource
    akonadi_openxchange_resource
    akonadi_vcarddir_resource
    akonadi_vcard_resource
  ];
}
