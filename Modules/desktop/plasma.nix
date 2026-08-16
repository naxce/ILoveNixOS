{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    dolphin
    dolphin-plugins
    baloo-widgets
    elisa
    kate
    ktexteditor
    khelpcenter
    ark
    ffmpegthumbs
    krdp
    plasma-browser-integration
    plasma-workspace-wallpapers
    kwin-x11
    qrca
    discover
  ];

  services.desktopManager.plasma6.enableQt5Integration = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "kde";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  /*
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "start-plasma" ''
        # Refuse to nest sessions or run outside a real TTY.
        if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
          echo "start-plasma: a graphical session is already running" >&2
          exit 1
        fi

        exec ${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland
      '')
    ];
  */

  programs.zsh.shellAliases = {
    kde = "startplasma-wayland";
  };
}
