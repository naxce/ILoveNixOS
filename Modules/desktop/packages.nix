{
  config,
  pkgs,
  pkgs-fonts,
  inputs,
  ...
}:

let
  llama-cpp =
    (pkgs.llama-cpp.override {
      cudaSupport = true;
    }).overrideAttrs
      (old: {
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [
          (pkgs.lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" "120")
        ];
      });

  vscodium = pkgs.vscodium.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      sed -i 's/;inode\/directory//' "$out/share/applications/codium.desktop"
    '';
  });
in
{

  environment.systemPackages = with pkgs; [

    inputs.sylvaris.packages.${pkgs.system}.default

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
    iloader
    kdePackages.partitionmanager

    photocraft
    libreoffice-qt
    grim
    slurp
    wl-clipboard
    xrandr
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
    uv
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
    libnotify
    gnome-calculator
    gnome-disk-utility
    xdg-desktop-portal-gtk

    prismlauncher
    protonup-qt
    protontricks
    steam
    steam-run
    steamtinkerlaunch
    heroic
    samrewritten
    wineWow64Packages.stable
    winetricks
    mangohud
    gamemode
    gamescope
    r2modman
    vulkan-tools
    vulkan-loader
    mesa-demos

    vesktop
    discord
    ferdium
    cider-2
    signal-desktop
    bitwarden-desktop

    filezilla
    nixfmt
    curl
    wget
    gnumake
    git
    llama-cpp
    lazygit
    claude-code
    antigravity-cli

    stremio-linux-shell

    python3
    ruff

    nodejs

    jdk21

    gcc
    clang

    rustup

    stylua
    shfmt

    gimp
    yt-dlp
    ffmpeg
    libimobiledevice

    pavucontrol

    bluez
    bluez-tools

    wireless-regdb

    kitty
    fastfetch
  ];

  xdg.mime.enable = true;
  xdg.menus.enable = true;
  xdg.icons.enable = true;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-source-record
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
    extensions =
      with pkgs.vscode-extensions;
      [
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
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "hoi4modutilities";
          publisher = "chaofan";
          version = "0.18.1";
          hash = "sha256-rMoObqJt3G1fCgtf+pDKcy9OJk5CGjkXbu97Ywco1n0=";
        }
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
