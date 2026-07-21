{ config, pkgs, ... }:

let
  hyprswitch = pkgs.callPackage ./hyprswitch.nix { };
in
{
  environment.systemPackages = with pkgs; [
    hyprswitch

    os-prober
    refind
    efibootmgr

    home-manager
    nvtopPackages.nvidia
    htop
    xnconvert
    qemu
    libvirt
    virt-manager
    lm_sensors
    unrar

    qbittorrent
    iw
    linux-wifi-hotspot
    chntpw

    waybar
    rofi
    hyprlock
    hypridle
    hyprpaper
    hyprpicker
    hyprsunset
    swaynotificationcenter
    hyprpolkitagent
    wlogout
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    imagemagick
    brightnessctl
    playerctl
    pamixer
    qt6Packages.qt6ct
    kdePackages.qtsvg
    nwg-look
    gtk3
    gtk4
    adw-gtk3
    yazi
    xdg-utils
    desktop-file-utils
    shared-mime-info
    file
    fd
    ripgrep
    fzf
    zoxide
    eza
    bat
    jq
    ffmpegthumbnailer
    poppler-utils
    chafa
    ueberzugpp
    trash-cli
    ouch
    p7zip
    zip
    unzip
    gnutar
    gzip
    xz
    bzip2
    zstd
    bibata-cursors
    papirus-icon-theme
    networkmanagerapplet
    blueman
    libnotify
    gnome-calculator
    gnome-disk-utility
    xdg-desktop-portal-gtk

    prismlauncher
    protonup-qt
    protontricks
    steam
    steam-run
    heroic
    samrewritten
    wineWow64Packages.stable
    winetricks
    mangohud
    gamemode
    gamescope
    steamtinkerlaunch
    r2modman
    vulkan-tools
    vulkan-loader
    mesa-demos

    firefox
    vesktop
    discord
    ferdium
    cider-2

    filezilla
    nixfmt
    curl
    wget
    gnumake
    git
    llama-cpp
    lazygit

    python3
    ruff

    jdk21

    gcc
    clang

    rustup

    nodejs_latest

    stylua
    shfmt

    obs-studio
    gimp
    yt-dlp
    ffmpeg

    pavucontrol

    bluez
    bluez-tools

    wireless-regdb

    kitty
    zenity

    sptlrx
    fastfetch
    tty-clock
    cmatrix
    toilet
    cbonsai
    pipes-rs
    lavat
    asciiquarium
    cava
  ];

  xdg.mime.enable = true;
  xdg.menus.enable = true;
  xdg.icons.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhsWithPackages (
      ps: with ps; [
        zlib
        openssl
        stdenv.cc.cc.lib
        nodejs
      ]
    );
    extensions = with pkgs.vscode-extensions; [
      ritwickdey.liveserver
      esbenp.prettier-vscode
      mvllow.rose-pine
      rust-lang.rust-analyzer
      ms-vscode.cpptools
      jnoortheen.nix-ide
      redhat.vscode-yaml
      yzhang.markdown-all-in-one
      anthropic.claude-code
      piousdeer.adwaita-theme
      ms-python.python
      charliermarsh.ruff
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-10.29.2"
  ];

  fonts.packages = with pkgs; [
    inter
    noto-fonts
    twemoji-color-font
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  services.flatpak.enable = true;
}
