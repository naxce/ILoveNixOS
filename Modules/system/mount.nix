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
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "nofail"

      "x-systemd.device-timeout=10"
    ];
  };
}
