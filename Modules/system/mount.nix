{
  config,
  pkgs,
  ...
}:
{
  boot.supportedFilesystems = [
    "btrfs"
  ];
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/5de2abcd-cc79-4115-bf57-2ffc1a9c428d";
    fsType = "btrfs";
    options = [ "nofail" ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/67298a78-e4a6-4815-afc5-1ef2cb16464e";
    }
  ];
}
