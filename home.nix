{ config, pkgs, ... }:

{
  home.username = "naxce";
  home.homeDirectory = "/home/naxce";
  programs.home-manager.enable = true;
  home.preferXdgDirectories = true;

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
    '';

    shellAliases = {
      wipe = "reset && fastfetch --config $(cat ~/.config/kitty-work/theme 2>/dev/null | sed 's/blue/work-blue.jsonc/;s/red/work-red.jsonc/;s/purple/work-purple.jsonc/' | xargs -I{} echo $HOME/NixOS/Config/fastfetch/{})";

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
        wipe
        echo blue > ~/.config/kitty-work/theme
        kitty @ set-colors --all "$HOME/NixOS/Config/kitty/work-blue.conf"
        fastfetch --config "$HOME/NixOS/Config/fastfetch/work-blue.jsonc"
        wipe
      '';

      kc2 = ''
        wipe
        echo red > ~/.config/kitty-work/theme
        kitty @ set-colors --all "$HOME/NixOS/Config/kitty/work-red.conf"
        fastfetch --config "$HOME/NixOS/Config/fastfetch/work-red.jsonc"
        wipe
      '';

      kc3 = ''
        wipe
        echo purple > ~/.config/kitty-work/theme
        kitty @ set-colors --all "$HOME/NixOS/Config/kitty/work-purple.conf"
        fastfetch --config "$HOME/NixOS/Config/fastfetch/work-purple.jsonc"
        wipe
      '';

      khelp = "wipe && echo -e \"\\n===============================\\nKITTY WORK HELP\\n===============================\\n\\nTABS\\nCtrl+Shift+T new tab\\nCtrl+Shift+W close tab\\nCtrl+Shift+Q close window\\n\\nSPLITS\\nCtrl+Shift+Enter split\\nCtrl+Alt+V split vertical\\nCtrl+Alt+H split horizontal\\n\\nNAVIGATION\\nCtrl+Alt+arrows\\n\\nRESIZE\\nCtrl+Shift+arrows\\n===============================\"";
    };
  };

  home.stateVersion = "26.05";
}
