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

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "start-hyprland" ''
      # Refuse to nest sessions or run outside a real TTY.
      if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
        echo "start-hyprland: a graphical session is already running" >&2
        exit 1
      fi

      export XDG_CURRENT_DESKTOP=Hyprland
      export XDG_SESSION_DESKTOP=Hyprland
      export LIBVA_DRIVER_NAME=nvidia
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export WLR_NO_HARDWARE_CURSORS=1

      exec ${pkgs.hyprland}/bin/Hyprland
    '')

    (pkgs.writeShellScriptBin "start-steam-bigpicture" ''
      # Refuse to nest sessions or run outside a real TTY.
      if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
        echo "start-steam-bigpicture: a graphical session is already running" >&2
        exit 1
      fi

      exec ${pkgs.gamescope}/bin/gamescope \
        --steam \
        -e \
        -f \
        -- ${pkgs.steam}/bin/steam -tenfoot -pipewire-dmabuf
    '')
  ];

  programs.zsh.shellAliases = {
    hl = "start-hyprland";
    sbp = "start-steam-bigpicture";
  };

  # Shared across every Wayland session on this machine (Hyprland + sway).
  # Session-identity vars (XDG_CURRENT_DESKTOP, XDG_SESSION_DESKTOP, GPU
  # driver hints, cursor mode, ...) differ per-compositor and are instead
  # set inside each compositor's own config so both can coexist without a
  # NixOS "conflicting definition" error on this shared option.
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
