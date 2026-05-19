{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Boot / EFI
    os-prober
    refind
    efibootmgr

    # Narzędzia systemowe
    home-manager
    kdePackages.kcalc
    git

    # KDE
    kdePackages.plasma-browser-integration
    kdePackages.plasma-keyboard
    qt6.qtVirtualKeyboard

    # Gry
    prismlauncher
    protonup-qt
    steam
    steam-run
    heroic
    wineWow64Packages.stable
    winetricks
    mangohud
    gamemode
    gamescope
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers

    # Internet / komunikacja
    firefox
    vesktop
    ferdium
    cider-2

    # Programowanie
    vscodium
    nixfmt
    ollama

    # Multimedia
    obs-studio

    # Audio
    pavucontrol

    # Bluetooth
    bluez
    bluez-tools

    # Sieć
    wireless-regdb

    # Terminal
    kitty
    zenity
    fastfetch
  ];

  fonts.packages = with pkgs; [
    inter
    noto-fonts
    noto-fonts-color-emoji
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # Flatpak
  services.flatpak.enable = true;
}
