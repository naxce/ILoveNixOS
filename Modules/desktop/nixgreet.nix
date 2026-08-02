{
  config,
  pkgs,
  lib,
  ...
}:
let
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.pygobject3
    ps.pillow
    ps.pycairo
  ]);

  nixgreetPy = ../../Config/nixgreet/nixgreet.py;
  nixgreetCss = ../../Config/nixgreet/nixgreet.css;

  nixgreetPkg = pkgs.stdenv.mkDerivation {
    pname = "nixgreet";
    version = "1.0.0";
    dontUnpack = true;
    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.wrapGAppsHook4
      pkgs.gobject-introspection
    ];
    buildInputs = [
      pkgs.gtk4
      pkgs.gtk4-layer-shell
      pkgs.adwaita-icon-theme
      pkgs.hicolor-icon-theme
      pkgs.glib
      pkgs.pango
      pkgs.cairo
      pkgs.gdk-pixbuf
      pkgs.graphene
      pkgs.harfbuzz
      pkgs.atk
      pythonEnv
    ];

    dontWrapGApps = false;

    installPhase = ''
      mkdir -p $out/share/nixgreet $out/bin
      cp ${nixgreetPy} $out/share/nixgreet/nixgreet.py
      cp ${nixgreetCss} $out/share/nixgreet/nixgreet.css

      makeWrapper ${pythonEnv}/bin/python3 $out/bin/nixgreet \
        --add-flags "$out/share/nixgreet/nixgreet.py" \
        --prefix LD_LIBRARY_PATH : "${pkgs.gtk4-layer-shell}/lib" \
        --prefix GI_TYPELIB_PATH : "${pkgs.gtk4-layer-shell}/lib/girepository-1.0" \
        --set LD_PRELOAD "${pkgs.gtk4-layer-shell}/lib/libgtk4-layer-shell.so" \
        --set GDK_BACKEND wayland \
        --set NIXGREET_WALLPAPER /etc/greetd/wallpaper.png \
        --set NIXGREET_MONITOR DP-6
    '';
  };
in
{
  services.displayManager.sddm.enable = false;
  services.xserver.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${nixgreetPkg}/bin/nixgreet";
        user = "greeter";
      };
    };
  };

  environment.etc."greetd/wallpaper.png".source = ../../Pictures/wallpapers/noir.png;

  environment.etc."greetd/environments".text = ''
    Hyprland|start-hyprland
  '';

  environment.systemPackages = [ nixgreetPkg ];
}
