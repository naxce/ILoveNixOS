{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/desktop/dewm.nix
    ./modules/desktop/gaming.nix
    ./modules/desktop/packages.nix

    ./modules/system/boot.nix
    ./modules/system/hardware.nix
    ./modules/system/mount.nix
    ./modules/system/network.nix
    ./modules/system/rules.nix
    ./modules/system/users.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}