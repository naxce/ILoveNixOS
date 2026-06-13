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
    device = "/dev/disk/by-uuid/186AAA106AA9EAA8";
    fsType = "ntfs";
    options = [
      "rw"
      "uid=1000"
      "nofail"
    ];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/3B3A1DA152B204A4";
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
