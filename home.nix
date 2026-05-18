{ config, pkgs, ... }:

{
  home.username = "naxce";
  home.homeDirectory = "/home/naxce";
  programs.home-manager.enable = true;
  home.preferXdgDirectories = true;

  home.packages = [
    (pkgs.writeShellScriptBin "kwork" ''
      exec kitty --class kitty-work --name kitty-work --config "$HOME/NixOS/.config/kitty/work.conf" "$@"
    '')
  ];

  home.file.".config/cava".source = ./Config/cava;
  home.file.".config/fastfetch".source = ./Config/fastfetch;
  home.file.".config/kitty".source = ./Config/kitty;
  home.file.".config/sptlrx".source = ./Config/sptlrx;

  programs.bash = {
    enable = true;

    initExtra = ''
            mkdir -p /tmp/kittywork

            cat << 'EOF' > /tmp/kittywork/fastfetch.jsonc
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
          "source": "~/NixOS/Pictures/LogoBlue.png",
          "type": "kitty",
          "width": 26,
          "height": 10,
          "padding": { "top": 2, "left": 2 }
        },
        "display": {
          "separator": " ➜ ",
          "color": { "keys": "blue" }
        },
        "modules": [
          "title",
          "separator",
          { "type": "os", "key": "󱄅", "format": "{2} {8}" },
          { "type": "kernel", "key": "󰌽", "format": "{2}" },
          { "type": "uptime", "key": "󱎫" },
          { "type": "shell", "key": "󱆃" },
          { "type": "cpu", "key": "󰻠", "format": "{1}" },
          { "type": "gpu", "key": "󰢮", "hideType": "integrated", "format": "{2}" },
          {
            "type": "display",
            "key": "󰍹",
            "compactType": "original-with-refresh",
            "format": "{1}x{2} @ {3}Hz"
          },
          { "type": "memory", "key": "󰑭" },
          { "type": "localip", "key": "󰩟", "showIpv6": false }
        ]
      }
      EOF

            wipe() {
              reset
              fastfetch --config /tmp/kittywork/fastfetch.jsonc
            }

            fastfetch --config /tmp/kittywork/fastfetch.jsonc
    '';

    shellAliases = {
      ff = "fastfetch --config /tmp/kittywork/fastfetch.jsonc";

      wipe = "reset && fastfetch --config /tmp/kittywork/fastfetch.jsonc";

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

      khelp = "wipe && echo -e \"\\n===============================\\nKITTY WORK HELP\\n===============================\\n\\nTABS\\nCtrl+Shift+T new tab\\nCtrl+Shift+W close tab\\nCtrl+Shift+Q close window\\n\\nSPLITS\\nCtrl+Shift+Enter split\\nCtrl+Alt+V split vertical\\nCtrl+Alt+H split horizontal\\n\\nNAVIGATION\\nCtrl+Alt+arrows\\n\\nRESIZE\\nCtrl+Shift+arrows\\n===============================\"";
    };
  };

  home.stateVersion = "26.05";
}
