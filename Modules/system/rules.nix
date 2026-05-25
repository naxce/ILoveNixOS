# rules.nix
{
  config,
  pkgs,
  ...
}:

{
  environment.sessionVariables = {
    QT_IM_MODULE = "maliit";
    XMODIFIERS = "@im=none";
    QT_QPA_PLATFORM = "wayland";
  };
  security.sudo.extraRules = [
    {
      users = [ "naxce" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-collect-garbage";

          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-shell";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/create_ap";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/home/naxce/NixOS/Scripts/reboot-to-windows.sh";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/tee /boot/EFI/refind/manual_boot.conf";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl reboot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/home/naxce/NixOS/Scripts/hotspot.sh";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/create_ap";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/pkill";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/ip";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/iw";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  security.polkit.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "naxce") {
        if (action.id == "org.freedesktop.policykit.exec" || 
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.blueman.network.setup" ||
            action.id == "org.blueman.rfkill.setstate" ||
            action.id == "org.blueman.pincode.confirm" ||
            action.id == "org.blueman.device.pair" ||
            action.id == "org.blueman.device.foregroundpair" ||
            action.id == "org.blueman.device.connect" ||
            action.id == "org.freedesktop.systemd1.manage-units") {
          return polkit.Result.YES;
        }
      }
    });
  '';
}
