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
  fileSystems."/mnt/void" = {
    device = "/dev/disk/by-uuid/5f0be456-4e60-4018-9de9-61df53981518";
    fsType = "ext4";
    options = [
      "rw"
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=10"
    ];
  };
}
