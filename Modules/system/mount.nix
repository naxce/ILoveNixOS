# mount.nix
{
  config,
  pkgs,
  ...
}:

{
  boot.supportedFilesystems = [ "ntfs3" ];
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/186AAA106AA9EAA8";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "nofail"
    ];
  };
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/3B3A1DA152B204A4";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "big_writes"
      "nofail"
    ];
  };
}
