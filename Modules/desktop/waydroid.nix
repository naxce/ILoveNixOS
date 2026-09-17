{ config, pkgs, ... }:

{
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  environment.systemPackages = with pkgs; [
    waydroid-helper

    wl-clipboard

    lzip
  ];

  systemd.packages = [ pkgs.waydroid-helper ];
  systemd.services.waydroid-mount.wantedBy = [ "multi-user.target" ];

  systemd.services.waydroid-container.preStart = ''
    prop=/var/lib/waydroid/waydroid_base.prop
    if [ -f "$prop" ]; then
      ${pkgs.gnused}/bin/sed -i \
        -e 's/^ro\.hardware\.gralloc=.*/ro.hardware.gralloc=default/' \
        -e 's/^ro\.hardware\.egl=.*/ro.hardware.egl=swiftshader/' \
        -e '/^ro\.hardware\.vulkan=/d' \
        -e '/^gralloc\.gbm\.device=/d' \
        "$prop"
    fi
  '';
}
