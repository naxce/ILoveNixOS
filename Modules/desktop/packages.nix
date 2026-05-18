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

    # Klawiatura ekranowa
    maliit-keyboard
    maliit-framework

    # Gry
    prismlauncher
    protonup-qt
    steam
    steam-run
    lutris
    heroic
    bottles
    wineWow64Packages.stable
    winetricks
    mangohud
    goverlay
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
