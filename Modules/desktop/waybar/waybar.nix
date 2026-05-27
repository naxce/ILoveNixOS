{
  config,
  pkgs,
  lib,
  ...
}:

let
  waybConf = ./config;
  waybCss = ./style.css;
in
{
  environment.etc = {
    "xdg/waybar/config" = {
      source = waybConf;
      mode = "0644";
    };
    "xdg/waybar/style.css" = {
      source = waybCss;
      mode = "0644";
    };
  };

  environment.sessionVariables = {
    XDG_CONFIG_DIRS = lib.mkDefault "/etc/xdg:$HOME/.config";
  };

  systemd.user.services.waybar = {
    description = "Waybar — Wayland bar";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.waybar}/bin/waybar";
      ExecReload = "kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      KillMode = "mixed";
    };
  };
}
