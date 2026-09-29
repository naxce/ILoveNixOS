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

  networking.firewall.allowedTCPPorts = [ ];

  virtualisation = {
    libvirtd.enable = true;

    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.variables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
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
    package = pkgs.openrgb.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        echo 'REGISTER_HID_DETECTOR_IP("Krux Atax Pro RGB", DetectEVisionV2Keyboards, SPCGEAR_VID, 0x2736, 1, EVISION_KEYBOARD_USAGE_PAGE);' \
          >> Controllers/EVisionKeyboardController/EVisionV2KeyboardController/EVisionV2KeyboardControllerDetect.cpp
      '';
    });
  };

  services.udisks2.enable = true;

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
