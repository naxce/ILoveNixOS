{
  config,
  pkgs,
  pkgs-stable,
  ...
}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.kernelPackages = pkgs-stable.linuxPackages_6_12;

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "split_lock_detect=off"
    "btusb.enable_autosuspend=0"
    "pcie_aspm=off"
  ];

  boot.kernelModules = [
    "btmtk"
    "btusb"
  ];
  boot.blacklistedKernelModules = [ "uvcvideo" ];
  boot.extraModprobeConfig = ''
    options btusb disable_scofix=1 enable_autosuspend=0
  '';

  boot.initrd.kernelModules = [
    "btmtk"
    "btusb"
  ];
  boot.initrd.includeDefaultModules = true;

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];
}
