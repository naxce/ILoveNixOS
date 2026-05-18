{ config, pkgs, ... }:

{
  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;

    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    localNetworkGameTransfers.openFirewall = true;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;

    "kernel.sched_autogroup_enabled" = 1;

    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  powerManagement.cpuFreqGovernor = "performance";

  services.power-profiles-daemon.enable = false;

  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
  };

  services.telemetry.enable = false;
  services.thermald.enable = true;
}
