{ config, pkgs, ... }:

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

  /*
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
  */

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  systemd.services.gpu-performance = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pm 1
        ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -lgc 300,2700
      '';
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
