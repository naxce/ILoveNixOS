{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  gtk4,
  gtk4-layer-shell,
  glib,
  cairo,
  pango,
  gdk-pixbuf,
  graphene,
}:

rustPlatform.buildRustPackage rec {
  pname = "hyprswitch";
  version = "063ff09";

  src = fetchFromGitHub {
    owner = "h3rmt";
    repo = "hyprshell";
    rev = "063ff09b74cdec2ede3a1567433064fd4a61b7d1";
    hash = "sha256-XvyyZuS78ETJl4QZm0kqVMRMAEmoZbp2UHBNLAl0pXQ=";
  };

  cargoHash = "sha256-DEifup2oAcqZplx2JoN3hkP1VmxwYVFS8ZqfpR80baA=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
    glib
    cairo
    pango
    gdk-pixbuf
    graphene
  ];

  doCheck = false;

  meta = with lib; {
    description = "A CLI/GUI that allows switching between windows in Hyprland";
    homepage = "https://github.com/h3rmt/hyprshell/tree/old-release-hyprswitch";
    license = licenses.mit;
    mainProgram = "hyprswitch";
    platforms = platforms.linux;
  };
}
