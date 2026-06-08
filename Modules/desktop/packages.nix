{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Boot / EFI
    os-prober
    refind
    efibootmgr

    # Narzędzia systemowe
    home-manager
    nvtopPackages.nvidia
    htop
    xnconvert
    qemu
    libvirt
    virt-manager
    lm_sensors
    unrar
    bottles

    # KDE
    kdePackages.kdeconnect-kde
    kdePackages.kcalc
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
    brave
    vesktop
    ferdium
    cider-2

    # Dev
    filezilla
    neovim
    nixfmt
    curl
    wget
    gnumake
    git
    # Python
    python3
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
    # Ricing
    sptlrx
    fastfetch
    tty-clock
    cmatrix
    cbonsai
    pipes-rs
    lavat
    asciiquarium
    cava
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
