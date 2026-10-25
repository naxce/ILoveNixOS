{
  config,
  pkgs,
  ...
}:
{
  boot.supportedFilesystems = [
    "ntfs"
    "ext4"
  ];
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/E818049F18046EBE";
    fsType = "ntfs";
    options = [
      "rw"
      "uid=1000"
      "nofail"
    ];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/36E9EE794FF8FD45";
    fsType = "ntfs";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "nofail"

      "x-systemd.device-timeout=10"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/d1508729-e6f5-4ed6-8553-fe5d5b50e79d";
    }
  ];
}
