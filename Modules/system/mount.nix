# mount.nix
{
  config,
  pkgs,
  ...
}:
{
  boot.supportedFilesystems = [
    "ntfs"
    "vfat"
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
      "x-systemd.automount"
      "x-systemd.device-timeout=10"
    ];
  };

  fileSystems."/mnt/pendrive" = {
    device = "/dev/disk/by-uuid/D4DA-86AA";
    fsType = "vfat";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "nofail"
      "x-systemd.automount"
    ];
  };
}
