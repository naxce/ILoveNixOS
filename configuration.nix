{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./Modules/desktop/dewm.nix
    ./Modules/desktop/gaming.nix
    ./Modules/desktop/packages.nix

    ./Modules/desktop/waybar/waybar.nix

    ./Modules/system/boot.nix
    ./Modules/system/hardware.nix
    ./Modules/system/mount.nix
    ./Modules/system/network.nix
    ./Modules/system/rules.nix
    ./Modules/system/users.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
