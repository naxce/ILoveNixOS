{ config, pkgs, lib, ... }:
let
  # Python + GTK4 + layer-shell bindings the greeter script needs.
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.pygobject3 ps.pillow ps.pycairo ]);

  nixgreetPy = ../../Config/nixgreet/nixgreet.py;
  nixgreetCss = ../../Config/nixgreet/nixgreet.css;

  # Wraps the raw script into a proper package so both files always ship
  # together and the .py can find its .css next to it at runtime.
  #
  # Rather than hand-picking GI typelibs one crash at a time (Graphene,
  # cairo, Pango, ... GTK4 pulls in a long transitive chain), this uses
  # wrapGAppsHook4 - the same nixpkgs mechanism GTK4 apps normally get for
  # free via `programs.something.enable` - which walks buildInputs and wires
  # up GI_TYPELIB_PATH, GDK_PIXBUF_MODULE_FILE, XDG_DATA_DIRS, etc. for
  # every GI-aware package found there, automatically.
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

    # wrapGAppsHook4 wraps whatever's in $out/bin automatically during
    # fixupPhase, so nixgreet just needs to end up there.
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

  # Same list the old regreet setup used — nixgreet reads this file to
  # populate its session dropdown, one session per line. A line can be
  # just an exec command, or "Display Name|exec-command" when the name
  # shown to the user should differ from what's actually run.
  #
  # Shown as "Hyprland" but launches "start-hyprland": since Hyprland
  # 0.53 the raw Hyprland binary detects when it wasn't launched through
  # the start-hyprland wrapper (it has crash recovery / safe-mode baked
  # in) and throws a warning banner on start. nixpkgs' hyprland package
  # already ships this wrapper as its own $out/bin/start-hyprland, so no
  # extra derivation is needed here — just make sure it's the one
  # actually invoked, while the picker still reads "Hyprland" to the user.
  environment.etc."greetd/environments".text = ''
    Hyprland|start-hyprland
  '';

  environment.systemPackages = [ nixgreetPkg ];
}
