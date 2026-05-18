# mount.nix
{
  config,
  pkgs,
  ...
}:

{
boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/186AAA106AA9EAA8";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
      "nofail"
    ];
  };
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/3B3A1DA152B204A4";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "umask=002"
      "nofail"
    ];
  };
}