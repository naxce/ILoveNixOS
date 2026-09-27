{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.sylvaris.nixosModules.sylvaris

    ./Modules/desktop/hyprland.nix
    ./Modules/desktop/sway.nix
    ./Modules/desktop/niri.nix
    ./Modules/desktop/gaming.nix
    ./Modules/desktop/packages.nix
    ./Modules/desktop/waydroid.nix

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

  programs.sylvaris.greeter = {
    enable = true;
    user = "naxce";
    session = "hyprland";
    swayConfig = ''
      output eDP-1 disable
      output HDMI-A-2 disable
      output DP-6 mode 2560x1440@200.013Hz position 1920 0
      output DP-5 mode 1920x1080@179.964Hz position 0 500
      input * xkb_layout pl
    '';
    environment.WLR_NO_HARDWARE_CURSORS = "1";
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";
}
