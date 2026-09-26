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
    theme = "noir";
    themes = builtins.mapAttrs (
      _: theme:
      removeAttrs theme [
        "links"
        "wallpaper"
      ]
    ) config.home-manager.users.naxce.programs.sylvaris.themes;
    wallpaper = ./Pictures/wallpapers/noir.png;
    settings.avatar = "${./Pictures/wallpapers/avatar.png}";
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";
}
