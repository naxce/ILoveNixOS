{
  config,
  pkgs,
  lib,
  ...
}:
let
  # hyprlogin: https://github.com/AuthenticSm1les/hyprlogin
  # Fork of hyprlock repurposed as a greetd greeter. Runs inside a real
  # Hyprland compositor (not cage), so it gets proper per-monitor
  # wlr-layer-shell surfaces - the same mirroring hyprlock.conf gets from
  # leaving `monitor =` blank, instead of the single-surface limitation
  # cage has (cage doesn't implement wlr-layer-shell-unstable per-output).
  #
  # Config syntax is the same hyprlang format hyprlock.conf uses, so the
  # visual config (Config/hyprlogin/hyprlogin.conf) is a near-verbatim copy
  # of hyprlock.conf, just with an added username input-field since the
  # greeter (unlike hyprlock) runs before any session/user is known.
  hyprloginPkg = pkgs.gcc15Stdenv.mkDerivation (finalAttrs: {
    pname = "hyprlogin";
    version = "0-unstable-2026-08-02";

    src = pkgs.fetchFromGitHub {
      owner = "AuthenticSm1les";
      repo = "hyprlogin";
      rev = "main";
      # NOTE: this is a rolling `main` checkout of a work-in-progress
      # project with no tagged releases. Nix requires a fixed content
      # hash for reproducibility - run `nix-prefetch-github
      # AuthenticSm1les hyprlogin --rev main` (or attempt the build once
      # and copy the hash Nix reports as "got:") and paste the real
      # value here before building. This placeholder will always fail.
      hash = "REPLACE_WITH_HYPRLOGIN_SRC_HASH";
    };

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
      hyprwayland-scanner
      wayland-scanner
    ];

    buildInputs = with pkgs; [
      cairo
      file
      hyprgraphics
      hyprlang
      hyprutils
      libdrm
      libGL
      libjpeg
      libwebp
      libxkbcommon
      libgbm
      pam
      pango
      sdbus-cpp_2
      systemdLibs
      wayland
      wayland-protocols
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
    ];

    # Upstream README only documents `cmake --build ./build --target
    # hyprlogin`; let the default install target run and fall back to
    # manually placing the binary if there's no `install` target defined.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      if [ -f hyprlogin ]; then
        install -Dm755 hyprlogin $out/bin/hyprlogin
      elif [ -f bin/hyprlogin ]; then
        install -Dm755 bin/hyprlogin $out/bin/hyprlogin
      else
        echo "hyprlogin binary not found after build - check upstream's CMakeLists.txt output location" >&2
        exit 1
      fi
      runHook postInstall
    '';

    meta = {
      description = "greetd greeter forked from hyprlock, runs under a real Hyprland session for true per-monitor mirroring";
      homepage = "https://github.com/AuthenticSm1les/hyprlogin";
      license = lib.licenses.bsd3;
      platforms = lib.platforms.linux;
    };
  });

  hyprlandGreeterConfig = ../../Config/hyprlogin/hyprland-greeter.lua;
  hyprloginConfig = ../../Config/hyprlogin/hyprlogin.conf;
in
{
  services.displayManager.sddm.enable = false;
  services.xserver.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland --config ${hyprlandGreeterConfig}";
        user = "greeter";
      };
    };
  };

  environment.etc."hyprlogin/hyprlogin.conf".source = hyprloginConfig;

  environment.etc."greetd/environments".text = ''
    Hyprland|start-hyprland
  '';

  environment.systemPackages = [
    hyprloginPkg
    pkgs.hyprland
  ];
}
