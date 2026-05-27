{
  config,
  pkgs,
  lib,
  ...
}:

{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  environment.etc = {
    "xdg/waybar/config" = {
      source = ./config;
      mode = "0644";
    };
    "xdg/waybar/style.css" = {
      source = ./style.css;
      mode = "0644";
    };
  };

  environment.etc."xdg/autostart/waybar.desktop" = {
    mode = "0644";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Waybar
      Exec=waybar
      Hidden=false
      X-KDE-AutostartEnabled=true
      X-KDE-StartupNotify=false
    '';
  };
}
