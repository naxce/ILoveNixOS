{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Boot / EFI
    os-prober
    refind
    efibootmgr

    # Archiwa
    peazip
    p7zip
    unrar

    # Narzędzia systemowe
    home-manager
    gnome-calculator
    plasma-browser-integration
    git

    # Klawiatura ekranowa
    maliit-keyboard
    maliit-framework

    # Gry
    prismlauncher
    mangohud
    gamemode
    gamescope
    protonup-qt
    vulkan-tools

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
