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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "split_lock_detect=off"
    "btusb.enable_autosuspend=0"
    "pcie_aspm=off"
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];

  systemd.services.restore-refind-default = {
    description = "Restore rEFInd";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      cat > /boot/EFI/refind/manual_boot.conf <<'EOF'
      timeout 5
      default_selection NixOS
      EOF
    '';
  };
}
