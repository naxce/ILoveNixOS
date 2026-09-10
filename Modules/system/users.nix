{ config, pkgs, ... }:

{

  programs.zsh.enable = true;

  users.users.naxce = {
    isNormalUser = true;
    description = "naxce";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "kvm"
      "video"
      "render"
      "input"
      "uinput"
      "i2c"
      "audio"
    ];
  };
}
