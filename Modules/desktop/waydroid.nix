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

  # Mamy kartę Nvidia (zamknięty sterownik) - Waydroid nie umie z niej
  # korzystać przez GBM, więc wymuszamy renderowanie programowe (swiftshader).
  # Domyślny prop (i skrypty typu waydroid-script instalujące libndk/GApps)
  # ciągle nadpisują to z powrotem na wartości pod AMD (gbm/mesa/radeon),
  # więc łatamy plik za każdym razem TUŻ PRZED startem kontenera, żeby
  # poprawka zawsze obowiązywała, niezależnie co zrobił wcześniej init/upgrade.
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
