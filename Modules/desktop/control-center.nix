{ config, pkgs, lib, ... }:
let
  # Must match APP_ID in control-center.py exactly — this is the
  # GApplication id that `gapplication launch` below uses to find/activate
  # the already-running instance instead of spawning a new process.
  APP_ID = "dev.nixos.control-center";

  # Python + GTK4 + layer-shell bindings, same stack nixgreet already uses.
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);

  controlCenterPy = ../../Config/control-center/control-center.py;
  controlCenterCss = ../../Config/control-center/control-center.css;

  controlCenterPkg = pkgs.stdenv.mkDerivation {
    pname = "control-center";
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
      mkdir -p $out/share/control-center $out/bin
      cp ${controlCenterPy} $out/share/control-center/control-center.py
      cp ${controlCenterCss} $out/share/control-center/control-center.css

      makeWrapper ${pythonEnv}/bin/python3 $out/bin/control-center-bin \
        --add-flags "$out/share/control-center/control-center.py" \
        --prefix LD_LIBRARY_PATH : "${pkgs.gtk4-layer-shell}/lib" \
        --prefix GI_TYPELIB_PATH : "${pkgs.gtk4-layer-shell}/lib/girepository-1.0" \
        --set LD_PRELOAD "${pkgs.gtk4-layer-shell}/lib/libgtk4-layer-shell.so" \
        --set GDK_BACKEND wayland \
        --set GTK_THEME Adwaita:dark \
        --set GTK_APPLICATION_PREFER_DARK_THEME 1
    '';
  };

  # control-center-bin now stays running in the background after the first
  # launch (it hides its window instead of quitting — see hide_panel() /
  # show_panel() in control-center.py) and uses a unique GApplication id, so
  # `gapplication launch` will activate that same already-warm process
  # instead of a brand new one being spawned + initialized from scratch.
  # That's what makes reopening the panel fast: no repeated
  # Python/GTK/layer-shell startup cost on the 2nd, 3rd, ... click.
  #
  # `gapplication launch` can only reach an already-running instance over
  # D-Bus (there's no .desktop file here for D-Bus to auto-spawn one from
  # cold), so: try to activate a running instance first, and if none owns
  # the app id yet, fall back to actually starting the process. Every
  # activation after that first one is a cheap D-Bus call to the
  # already-warm process — no repeated Python/GTK/layer-shell startup.
  controlCenterToggle = pkgs.writeShellScriptBin "control-center" ''
    set -euo pipefail
    if ${pkgs.glib}/bin/gapplication launch ${APP_ID} 2>/dev/null; then
      exit 0
    fi
    # Cold start only: the process now stays alive in the background
    # (app.hold() in control-center.py) waiting for future D-Bus
    # activations above, so it must be launched detached here — otherwise
    # this script, and the waybar click that ran it, would block for as
    # long as the panel process keeps running (i.e. until logout).
    disown -a 2>/dev/null || true
    nohup ${controlCenterPkg}/bin/control-center-bin >/dev/null 2>&1 &
    disown
  '';
in
{
  environment.systemPackages = [
    controlCenterPkg
    controlCenterToggle
  ];
}
