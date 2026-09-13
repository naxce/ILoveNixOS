{ config, pkgs, ... }:

{
  # Waydroid - natywny kontener Android (LXC) na kernelu hosta.
  # Odpowiednik BlueStacks/Genymotion, ale natywny i szybki na Wayland
  # (Hyprland/Sway). Nie ma emulacji CPU jak QEMU - Android biega
  # bezpośrednio na Twoim jądrze, tylko odizolowany w kontenerze.
  virtualisation.waydroid = {
    enable = true;
    # nixpkgs-unstable ma już jądro >= 6.16.9, gdzie moduł ip_tables
    # nie jest domyślnie dostępny - Waydroid wymaga wtedy wariantu nftables.
    package = pkgs.waydroid-nftables;
  };

  environment.systemPackages = with pkgs; [
    # GUI do zarządzania rozszerzeniami Waydroida: GApps (Sklep Play),
    # Magisk, warstwa tłumaczenia ARM, współdzielone foldery.
    waydroid-helper

    # Wklejanie schowka host <-> kontener Android.
    wl-clipboard

    # Wymagane przez skrypty instalujące libndk/libhoudini/GApps.
    lzip
  ];

  # Usługa systemd dostarczana przez waydroid-helper, pozwala
  # na montowanie katalogów hosta wewnątrz kontenera Android
  # (np. żeby przerzucić .apk albo zapisy z gier).
  systemd.packages = [ pkgs.waydroid-helper ];
  systemd.services.waydroid-mount.wantedBy = [ "multi-user.target" ];
}
