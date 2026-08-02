{
  config,
  pkgs,
  lib,
  ...
}:
let
  APP_ID = "dev.nixos.control-center";

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
        --set GTK_APPLICATION_PREFER_DARK_THEME 1
    '';
  };

  controlCenterToggle = pkgs.writeShellScriptBin "control-center" ''
    set -euo pipefail

    target_dir="$HOME/.cache/control-center"
    mkdir -p "$target_dir"
    target_file="$target_dir/target-monitor"

    pos="$(hyprctl cursorpos -j 2>/dev/null || true)"
    mons="$(hyprctl monitors -j 2>/dev/null || true)"
    if [ -n "$pos" ] && [ -n "$mons" ]; then
      x="$(echo "$pos" | jq -r '.x' 2>/dev/null || true)"
      y="$(echo "$pos" | jq -r '.y' 2>/dev/null || true)"
      if [ -n "$x" ] && [ -n "$y" ]; then
        mon="$(echo "$mons" | jq -r --argjson x "$x" --argjson y "$y" '
          (.[] | select(.x <= $x and $x < (.x + .width) and .y <= $y and $y < (.y + .height)) | .name) // empty
        ' 2>/dev/null || true)"
        if [ -n "$mon" ]; then
          printf '%s' "$mon" > "$target_file"
        fi
      fi
    fi

    if ${pkgs.glib}/bin/gapplication launch ${APP_ID} 2>/dev/null; then
      exit 0
    fi
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
