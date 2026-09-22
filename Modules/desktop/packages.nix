{
  config,
  pkgs,
  pkgs-fonts,
  ...
}:

let
  hyprswitch = pkgs.callPackage ./hyprswitch.nix { };

  claude-code-pin-overlay = final: prev: {
    claude-code = prev.claude-code.override {
      manifest = {
        version = "2.1.280";
        platforms = {
          "linux-x64" = {
            binary = "claude.zst";
            checksum = sha256-J5EOKucE2PLoAkiX2P3x53EIB7r09pgsDjeXwFgxU4Q=;
          };
        };
      };
    };

    vscode-extensions = prev.vscode-extensions // {
      anthropic = (prev.vscode-extensions.anthropic or { }) // {
        claude-code = final.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "claude-code";
            publisher = "anthropic";
            version = "2.1.280";
            arch = "linux-x64";
            hash = final.lib.fakeHash;
          };
          nativeBuildInputs = final.lib.optionals final.stdenv.hostPlatform.isLinux [
            final.autoPatchelfHook
          ];
          buildInputs = final.lib.optionals final.stdenv.hostPlatform.isLinux [
            (final.lib.getLib final.stdenv.cc.cc)
            final.alsa-lib
          ];
          meta = with final.lib; {
            description = "Harness the power of Claude Code without leaving your IDE";
            homepage = "https://docs.anthropic.com/s/claude-code";
            downloadPage = "https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code";
            license = licenses.unfree;
            platforms = [ "x86_64-linux" ];
          };
        };
      };
    };
  };
in
{
  nixpkgs.overlays = [ claude-code-pin-overlay ];

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
    quickemu
    quickgui
    gparted-full
    hyprpolkitagent

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
    file-roller
    nemo-with-extensions
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
    signal-desktop
    libreoffice

    filezilla
    nixfmt
    curl
    wget
    gnumake
    git
    llama-cpp
    lazygit
    claude-code
    claude-monitor

    python3
    ruff

    jdk21

    gcc
    clang

    rustup

    stylua
    shfmt

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

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
    ];
  };

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

  fonts.packages =
    (with pkgs; [
      inter
      noto-fonts
      twemoji-color-font
      nerd-fonts.symbols-only
    ])
    ++ (with pkgs-fonts; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ]);

  services.flatpak.enable = true;
  programs.nix-ld.enable = true;
}
