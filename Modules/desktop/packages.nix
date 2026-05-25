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
    nvtopPackages.nvidia
    htop
    xnconvert
    qemu
    libvirt
    virt-manager

    # KDE
    xdg-desktop-portal-kde
    kdePackages.plasma-browser-integration
    kdePackages.kdeconnect-kde
    maliit-keyboard
    maliit-framework

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

    # Dev
    filezilla
    neovim
    nixfmt
    ollama
    curl
    wget
    cudatoolkit
    gnumake
    # C
    gcc
    clang
    # Rust
    rustup
    # JavaScript
    nodejs_latest

    # Multimedia
    obs-studio
    gimp

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
