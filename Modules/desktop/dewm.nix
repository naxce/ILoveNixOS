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

  environment.sessionVariables = {
    MALIIT_PLUGINS_DIRS = "/run/current-system/sw/lib/maliit/plugins";
  };

  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (
        kdeFinal: kdePrev: {
          maliit-framework = kdePrev.maliit-framework.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              mkdir -p $out/lib/maliit/plugins
              ln -s ${kdeFinal.maliit-keyboard}/lib/maliit/plugins/libmaliit-keyboard-plugin.so \
                $out/lib/maliit/plugins/libmaliit-keyboard-plugin.so
            '';
          });
        }
      );
    })
  ];

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
