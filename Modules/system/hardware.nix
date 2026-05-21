{
  config,
  pkgs,
  pkgs-stable,
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

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "127.0.0.1";
    port = 11434;
    loadModels = [ "qwen2.5-coder:32b" ];
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
    profiles.default.extensions = with pkgs.vscode-extensions; [
      continue.continue
      esbenp.prettier-vscode
      mvllow.rose-pine
      rust-lang.rust-analyzer
      ms-vscode.cpptools
      jnoortheen.nix-ide
    ];
  };

  networking.firewall.allowedTCPPorts = [ ];

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
}
