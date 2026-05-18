# ~/NixOS/system/users.nix
{ config, pkgs, ... }:

{
  users.users.naxce = {
    isNormalUser = true;
    description = "naxce";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "video"
      "render"
      "input"
      "uinput"
      "i2c"
      "audio"
    ];
  };
}
