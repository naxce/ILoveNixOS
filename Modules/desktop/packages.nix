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
    qbittorrent
    iw

    # KDE
    kdePackages.kcalc
    kdePackages.kfind
    maliit-keyboard
    maliit-framework
    libnotify

    # Gry
    prismlauncher
    protonup-qt
    protontricks
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
    mesa-demos

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
    # Java
    jdk21
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
    twemoji-color-font
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}
