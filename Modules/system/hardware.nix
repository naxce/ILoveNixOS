{
  config,
  pkgs,
  ...
}:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "dual";
        Experimental = true;
        FastConnectable = true;
      };
    };
  };

  services.blueman.enable = true;

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
    ];
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs [
    stdenv.cc.cc
    glibc
    libX11
    libXext
    libXcursor
    libXrandr
    libXi
    vulkan-loader
  ];

  networking.firewall.allowedTCPPorts = [ ];

  virtualisation.libvirtd.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb;
  };

  systemd.user.services.openrgb-profile = {
    description = "Load OpenRGB Profile 1 on Startup";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.openrgb}/bin/openrgb --profile 1";
      RemainAfterExit = true;
    };
  };
}
