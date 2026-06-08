# home.nix
{ config, pkgs, ... }:

{
  home.username = "naxce";
  home.homeDirectory = "/home/naxce";
  programs.home-manager.enable = true;
  home.preferXdgDirectories = true;

  xdg.configFile."kwinrc".text =
    let
      kzonesRaw = builtins.readFile ./Config/kwin/kzones.json;
      kzonesEscaped = builtins.replaceStrings [ "\n" ] [ "\\n" ] kzonesRaw;
    in
    ''
      [Desktops]
      Id_1=c3c67fa2-bbe1-4485-8d05-2ef9295c00e1
      Number=1
      Rows=1

      [Effect-blur]
      BlurStrength=8
      NoiseStrength=0
      Saturation=100

      [Effect-translucency]
      Menus=29

      [Plugins]
      blurEnabled=true
      dimscreenEnabled=false
      kzonesEnabled=true
      overviewEnabled=false
      trackmouseEnabled=true
      translucencyEnabled=true

      [Script-kzones]
      layoutsJson=${kzonesEscaped}

      [Tiling][c3c67fa2-bbe1-4485-8d05-2ef9295c00e1][5141d9d1-4740-4e9a-a08f-c6d29c2e60ec]
      padding=4
      tiles={"layoutDirection":"horizontal","tiles":[{"width":0.25},{"width":0.5},{"width":0.25}]}

      [Tiling][c3c67fa2-bbe1-4485-8d05-2ef9295c00e1][54a993d2-9e9e-407c-b2f0-7449484e3bdd]
      padding=4
      tiles={"layoutDirection":"horizontal","tiles":[{"width":0.25},{"width":0.5},{"width":0.25}]}

      [Tiling][c3c67fa2-bbe1-4485-8d05-2ef9295c00e1][a3323bf6-8adf-4d21-a526-b9da97e27c94]
      padding=4
      tiles={"layoutDirection":"horizontal","tiles":[{"width":0.6088541666666746},{"width":0.3911458333333254}]}

      [Tiling][c3c67fa2-bbe1-4485-8d05-2ef9295c00e1][c11abbc2-c8ea-4e98-aca3-9eadf5fe774c]
      padding=4
      tiles={"layoutDirection":"horizontal","tiles":[{"width":0.35664062500000226},{"width":0.4800781249999928},{"width":0.16328125000000493}]}

      [Wayland]
      VirtualKeyboardEnabled=true

      [Xwayland]
      Scale=1
      VirtualKeyboardEnabled=true

      [org.kde.kdecoration2]
      BorderSize=None
      BorderSizeAuto=false
      ButtonsOnLeft=
      library=org.kde.kwin.aurorae.v2
      theme=__aurorae__svg__Carl
    '';

  home.packages = [
    (pkgs.writeShellScriptBin "kwork" ''
      THEME_FILE="$HOME/.config/kitty-work/theme"

      mkdir -p "$HOME/.config/kitty-work"

      if [ ! -f "$THEME_FILE" ]; then
        echo "blue" > "$THEME_FILE"
      fi

      THEME=$(cat "$THEME_FILE")

      case "$THEME" in
        blue)
          CONF="$HOME/NixOS/Config/kitty/work-blue.conf"
          ;;
        red)
          CONF="$HOME/NixOS/Config/kitty/work-red.conf"
          ;;
        purple)
          CONF="$HOME/NixOS/Config/kitty/work-purple.conf"
          ;;
        *)
          CONF="$HOME/NixOS/Config/kitty/work-blue.conf"
          ;;
      esac

      exec ${pkgs.kitty}/bin/kitty \
        --class kitty-work \
        --name kitty-work \
        --config "$CONF" \
        "$@"
    '')
  ];

  home.file.".config/cava".source = ./Config/cava;
  home.file.".config/fastfetch".source = ./Config/fastfetch;
  home.file.".config/kitty".source = ./Config/kitty;
  home.file.".config/sptlrx".source = ./Config/sptlrx;

  programs.bash = {
    enable = true;

    initExtra = ''
      wipe

      archivefix() {
        STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/271590" \
        "$HOME/.local/share/Steam/steamapps/common/Proton - Experimental/files/bin/wine" \
        "/mnt/data/Games/Steam/steamapps/common/Grand Theft Auto V Enhanced/ArchiveFix.exe" "$1"
      }
    '';

    shellAliases = {
      robot = ''
        sudo systemctl reboot
      '';
      komasz = ''
        sudo systemctl poweroff
      '';
      israel = ''
        sudo sh -c 'echo 1 > /proc/sys/kernel/sysrq' && echo c | sudo tee /proc/sysrq-trigger
      '';

      wipe = ''
        reset

        THEME=$(cat ~/.config/kitty-work/theme 2>/dev/null || echo blue)

        case "$THEME" in
          red)
            FF="$HOME/NixOS/Config/fastfetch/work-red.jsonc"
            ;;
          purple)
            FF="$HOME/NixOS/Config/fastfetch/work-purple.jsonc"
            ;;
          *)
            FF="$HOME/NixOS/Config/fastfetch/work-blue.jsonc"
            ;;
        esac

        fastfetch --config "$FF"
      '';

      nixhelp = "wipe && echo -e \"\\nnixos: update + rebuild + push\\nnixgit: commit only\\nnixbuild: rebuild\\nnixhome: home-manager switch\\nnixkde: restart plasma\\nnixclean: garbage cleanup\\n\"";

      nixos = ''
        wipe
        cd ~/NixOS || exit

        msg="$*"
        [ -z "$msg" ] && msg="Update Commit"

        git add .
        git commit -m "$msg" || true
        git push origin main

        sudo nixos-rebuild switch --flake .#naxce
      '';

      nixup = ''
        wipe
        cd ~/NixOS || exit

        nix flake update

        msg="$*"
        [ -z "$msg" ] && msg="Update Commit"

        git add .
        git commit -m "$msg" || true
        git push origin main

        sudo nixos-rebuild switch --flake .#naxce
      '';

      nixgit = ''
        wipe
        cd ~/NixOS || exit

        msg="$*"
        [ -z "$msg" ] && msg="Update Commit"

        git add .
        git commit -m "$msg" || true
        git push origin main
      '';

      nixbuild = ''
        wipe
        cd ~/NixOS || exit
        sudo nixos-rebuild switch --flake .#naxce
      '';

      nixhome = ''
                wipe
        cd ~/NixOS || exit

        msg="$*"
        [ -z "$msg" ] && msg="Update Commit"

        git add .
        git commit -m "$msg" || true
        git push origin main
        home-manager switch --flake ~/NixOS#naxce
      '';

      nixkde = ''
        wipe
        kquitapp5 plasmashell || true
        plasmashell --replace & disown
      '';

      nixclean = ''
        wipe
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
      '';

      nixsh = ''
        wipe
        nix-shell
      '';

      rice = "wipe && ~/NixOS/scripts/rice.sh";

      kc1 = ''
        echo blue > ~/.config/kitty-work/theme
        kitty @ set-colors --all "$HOME/NixOS/Config/kitty/work-blue.conf"
        reset
        fastfetch --config "$HOME/NixOS/Config/fastfetch/work-blue.jsonc"
        pkill kwork
        kwork
      '';

      kc2 = ''
        echo red > ~/.config/kitty-work/theme
        kitty @ set-colors --all "$HOME/NixOS/Config/kitty/work-red.conf"
        reset
        fastfetch --config "$HOME/NixOS/Config/fastfetch/work-red.jsonc"
        pkill kwork
        kwork
      '';

      kc3 = ''
        echo purple > ~/.config/kitty-work/theme
        kitty @ set-colors --all "$HOME/NixOS/Config/kitty/work-purple.conf"
        reset
        fastfetch --config "$HOME/NixOS/Config/fastfetch/work-purple.jsonc"
        pkill kwork
        kwork
      '';

      kc = ''
        wipe
        echo -e kc1: Blue
        echo -e kc2: Red
        echo -e kc3: Purple
      '';

      khelp = ''wipe && echo -e \"\\n===============================\\nKITTY WORK HELP\\n===============================\\n\\nTABS\\nCtrl+Shift+T new tab\\nCtrl+Shift+W close tab\\nCtrl+Shift+Q close window\\n\\nSPLITS\\nCtrl+Shift+Enter split\\nCtrl+Alt+V split vertical\\nCtrl+Alt+H split horizontal\\n\\nNAVIGATION\\nCtrl+Alt+arrows\\n\\nRESIZE\\nCtrl+Shift+arrows\\n===============================\'';
    };
  };

  home.stateVersion = "26.05";
}
