{ config, pkgs, inputs, ... }:

{
  home.username = "naxce";
  home.homeDirectory = "/home/naxce";
  programs.home-manager.enable = true;
  home.preferXdgDirectories = true;

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  fonts.fontconfig = {
    enable = true;

    defaultFonts.emoji = [
      "Twemoji Color Emoji"
    ];
  };

  xdg.configFile."fontconfig/conf.d/10-emoji.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>

      <alias>
        <family>emoji</family>
        <prefer>
          <family>Twemoji Color Emoji</family>
        </prefer>
      </alias>

      <match target="pattern">
        <test name="family" qual="any">
          <string>emoji</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Twemoji Color Emoji</string>
        </edit>
      </match>

    </fontconfig>
  '';

  home.packages = [
    inputs.fatest.packages.${pkgs.system}.default

    (pkgs.writeShellScriptBin "kwork" ''
      exec ${pkgs.kitty}/bin/kitty \
        --class kitty-work \
        --name kitty-work \
        --config "$HOME/NixOS/Config/kitty/work.conf" \
        "$@"
    '')

    (pkgs.writeShellScriptBin "yazi-noir" ''
      exec ${pkgs.kitty}/bin/kitty \
        --class yazi-fm \
        --name yazi-fm \
        --title "Yazi Noir" \
        ${pkgs.yazi}/bin/yazi "$@"
    '')

    (pkgs.writeShellScriptBin "hotkeys" ''
      export PATH="${pkgs.fzf}/bin:${pkgs.util-linux}/bin:$PATH"
      exec "$HOME/NixOS/Scripts/hotkeys.sh"
    '')

    (pkgs.writeShellScriptBin "yazi-open" ''
      set -euo pipefail

      target="''${1:-$HOME}"

      if [[ "''$target" == file://* ]]; then
        target="$(${pkgs.python3}/bin/python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(urllib.parse.urlparse(sys.argv[1]).path))' "''$target")"
      fi

      if [[ -f "''$target" ]]; then
        cwd="$(${pkgs.coreutils}/bin/dirname -- "''$target")"
      elif [[ -d "''$target" ]]; then
        cwd="''$target"
      else
        target="$HOME/Downloads"
        cwd="$target"
      fi

      exec ${pkgs.kitty}/bin/kitty \
        --class yazi-fm \
        --name yazi-fm \
        --title "Yazi Noir" \
        --directory "''$cwd" \
        ${pkgs.yazi}/bin/yazi "''$target"
    '')
  ];

  home.file.".config/cava".source = ./Config/cava;
  home.file.".config/fastfetch".source = ./Config/fastfetch;
  home.file.".config/kitty".source = ./Config/kitty;
  home.file.".config/sptlrx".source = ./Config/sptlrx;
  home.file.".config/nvim".source = ./Config/nvim;
  home.file.".config/hypr/autostart.conf".source = ./Config/hypr/autostart.conf;
  home.file.".config/hypr/binds.conf".source = ./Config/hypr/binds.conf;
  home.file.".config/hypr/hypridle.conf".source = ./Config/hypr/hypridle.conf;
  home.file.".config/hypr/hyprland.conf".source = ./Config/hypr/hyprland.conf;
  home.file.".config/hypr/hyprlock.conf".source = ./Config/hypr/hyprlock.conf;
  home.file.".config/hypr/hyprpaper.conf".source = ./Config/hypr/hyprpaper.conf;
  home.file.".config/hypr/input.conf".source = ./Config/hypr/input.conf;
  home.file.".config/hypr/looknfeel.conf".source = ./Config/hypr/looknfeel.conf;
  home.file.".config/hypr/monitors.conf".source = ./Config/hypr/monitors.conf;
  home.file.".config/hypr/windowrules.conf".source = ./Config/hypr/windowrules.conf;

  home.activation.hyprLocalOverrides = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    localDir="$HOME/.config/hypr/local"
    $DRY_RUN_CMD mkdir -p "$localDir"
    for f in monitors.conf looknfeel.conf input.conf gaming.conf; do
      if [ ! -e "$localDir/$f" ]; then
        $DRY_RUN_CMD touch "$localDir/$f"
      fi
    done
  '';

  home.file.".config/waybar".source = ./Config/waybar;
  home.file.".config/rofi".source = ./Config/rofi;
  home.file.".config/swaync".source = ./Config/swaync;
  home.file.".config/wlogout".source = ./Config/wlogout;
  home.file.".config/swappy".source = ./Config/swappy;
  home.file.".config/yazi".source = ./Config/yazi;

  home.file.".config/hyprswitch".source = ./Config/hyprswitch;
  home.file."Pictures/wallpapers".source = ./Pictures/wallpapers;
  home.file."Pictures/Screenshots/.keep".text = "";

  xdg.desktopEntries.yazi-noir = {
    name = "Yazi Noir";
    genericName = "File Manager";
    comment = "Terminal file manager for Hyprland noir setup";
    exec = "yazi-open %U";
    icon = "system-file-manager";
    terminal = false;
    categories = [
      "System"
      "FileManager"
    ];
    mimeType = [
      "inode/directory"
      "application/zip"
      "application/x-zip"
      "application/x-zip-compressed"
      "application/x-7z-compressed"
      "application/vnd.rar"
      "application/x-rar"
      "application/x-rar-compressed"
      "application/x-tar"
      "application/gzip"
      "application/x-gzip"
      "application/x-bzip"
      "application/x-bzip2"
      "application/x-xz"
      "application/zstd"
      "application/x-zstd"
      "application/x-compressed-tar"
      "application/x-bzip-compressed-tar"
      "application/x-xz-compressed-tar"
      "application/x-zstd-compressed-tar"
    ];
  };

  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "yazi-noir.desktop" ];

      "application/zip" = [ "yazi-noir.desktop" ];
      "application/x-zip" = [ "yazi-noir.desktop" ];
      "application/x-zip-compressed" = [ "yazi-noir.desktop" ];
      "application/x-7z-compressed" = [ "yazi-noir.desktop" ];
      "application/vnd.rar" = [ "yazi-noir.desktop" ];
      "application/x-rar" = [ "yazi-noir.desktop" ];
      "application/x-rar-compressed" = [ "yazi-noir.desktop" ];
      "application/x-tar" = [ "yazi-noir.desktop" ];
      "application/gzip" = [ "yazi-noir.desktop" ];
      "application/x-gzip" = [ "yazi-noir.desktop" ];
      "application/x-bzip" = [ "yazi-noir.desktop" ];
      "application/x-bzip2" = [ "yazi-noir.desktop" ];
      "application/x-xz" = [ "yazi-noir.desktop" ];
      "application/zstd" = [ "yazi-noir.desktop" ];
      "application/x-zstd" = [ "yazi-noir.desktop" ];
      "application/x-compressed-tar" = [ "yazi-noir.desktop" ];
      "application/x-bzip-compressed-tar" = [ "yazi-noir.desktop" ];
      "application/x-xz-compressed-tar" = [ "yazi-noir.desktop" ];
      "application/x-zstd-compressed-tar" = [ "yazi-noir.desktop" ];
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
      lazygit
      stylua
      shfmt
      unzip
      gnutar
      gcc
      nodejs_latest
      tree-sitter
      nil
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
      style = "numbers,changes,header";
    };
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./Config/starship/starship.toml);
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    initContent = ''

      bindkey -v
      export KEYTIMEOUT=15

      autoload -Uz up-line-or-search down-line-or-search
      zle -N up-line-or-search
      zle -N down-line-or-search
      bindkey '^[[A' up-line-or-search
      bindkey '^[[B' down-line-or-search
      bindkey -M vicmd '^[[A' up-line-or-search
      bindkey -M vicmd '^[[B' down-line-or-search

      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
      zstyle ':fzf-tab:complete:(nvim|cat|bat):*' fzf-preview 'bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || eza -1 --color=always --icons=always $realpath'
      zstyle ':fzf-tab:*' switch-group ',' '.'
      zstyle ':fzf-tab:*' fzf-flags '--color=fg:#e8e8e8,bg:#000000,hl:#ffffff' '--color=fg+:#ffffff,bg+:#1a1a1a,hl+:#ffffff' '--color=border:#4d4d4d,prompt:#ffffff,pointer:#ffffff'

      clear
      fastfetch --config "$HOME/NixOS/Config/fastfetch/work.jsonc" 2>/dev/null

      yy() {
        local tmp
        tmp="$(mktemp -t yazi-cwd.XXXXXX)"
        yazi --cwd-file="$tmp" "$@"
        if cwd="$(cat "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          cd "$cwd" || return
        fi
        rm -f "$tmp"
      }

      eval "$(zoxide init zsh)"
    '';

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    shellAliases = {
      robot = "sudo systemctl reboot";
      komasz = "sudo systemctl poweroff";
      israel = "sudo sh -c 'echo 1 > /proc/sys/kernel/sysrq' && echo c | sudo tee /proc/sysrq-trigger";

      wipe = ''reset && fastfetch --config "$HOME/NixOS/Config/fastfetch/work.jsonc"'';

      cmatrix = "cmatrix -C white";

      nixhelp = "wipe && echo -e \"\\nnixos: update + rebuild + push\\nnixgit: commit only\\nnixbuild: rebuild\\nnixhome: home-manager switch\\nnixhypr: home-manager switch + hyprctl reload\\nnixclean: garbage cleanup\\ngaming: low-latency mode for games\\nungaming: restore full rice\\nhotkeys: interactive keybindings menu\\n\"";

      nixos = ''
        wipe
        cd ~/NixOS || exit
        msg="$*"; [ -z "$msg" ] && msg="Update Commit"
        git add .
        git commit -m "$msg" || true
        git push origin main
        sudo nixos-rebuild switch --flake .
      '';

      nixup = ''
        wipe
        cd ~/NixOS || exit
        nix flake update
        msg="$*"; [ -z "$msg" ] && msg="Update Commit"
        git add .
        git commit -m "$msg" || true
        git push origin main
        sudo nixos-rebuild switch --flake .
      '';

      nixgit = ''
        wipe
        cd ~/NixOS || exit
        msg="$*"; [ -z "$msg" ] && msg="Update Commit"
        git add .
        git commit -m "$msg" || true
        git push origin main
      '';

      nixbuild = ''
        wipe
        cd ~/NixOS || exit
        sudo nixos-rebuild switch --flake .
      '';

      nixhome = ''
        wipe
        cd ~/NixOS || exit
        msg="$*"; [ -z "$msg" ] && msg="Update Commit"
        git add .
        git commit -m "$msg" || true
        git push origin main
        home-manager switch --flake ~/NixOS
      '';

      nixhypr = ''
        wipe
        nixhome
        hyprctl reload
        hyprctl configerrors
      '';

      nixclean = ''
        wipe
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
      '';

      nixdev = ''
        wipe
        nix develop
      '';

      y = "yazi";
      yz = "yazi-noir";
      fm = "yazi-noir";

      gaming = "~/NixOS/Scripts/gaming.sh";
      ungaming = "~/NixOS/Scripts/rice-restore.sh";

      v = "nvim";
      vim = "nvim";
      lg = "lazygit";

      ls = "eza --icons=always --group-directories-first";
      ll = "eza --icons=always --group-directories-first -l --git";
      la = "eza --icons=always --group-directories-first -la --git";
      lt = "eza --icons=always --group-directories-first --tree --level=2";
      cat = "bat --style=plain --paging=never";
    };
  };

  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

  programs.bash = {
    enable = true;

    initExtra = ''
      PS1='\[\e[37m\][\u@\h:\w]\$\[\e[0m\] '
      wipe

      yy() {
        local tmp
        tmp="$(mktemp -t yazi-cwd.XXXXXX)"
        yazi --cwd-file="$tmp" "$@"
        if cwd="$(cat "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          cd "$cwd" || return
        fi
        rm -f "$tmp"
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
        fastfetch --config "$HOME/NixOS/Config/fastfetch/work.jsonc"
      '';

      nixhelp = "wipe && echo -e \"\\nnixos: update + rebuild + push\\nnixgit: commit only\\nnixbuild: rebuild\\nnixhome: home-manager switch\\nnixhypr: home-manager switch + hyprctl reload\\nnixclean: garbage cleanup\\ngaming: low-latency mode for games\\nungaming: restore full rice\\nhotkeys: interactive keybindings menu\\n\"";

      nixos = ''
        wipe
        cd ~/NixOS || exit

        msg="$*"
        [ -z "$msg" ] && msg="Update Commit"

        git add .
        git commit -m "$msg" || true
        git push origin main

        sudo nixos-rebuild switch --flake .
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

        sudo nixos-rebuild switch --flake .
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
        sudo nixos-rebuild switch --flake .
      '';

      nixhome = ''
        wipe
        cd ~/NixOS || exit

        msg="$*"
        [ -z "$msg" ] && msg="Update Commit"

        git add .
        git commit -m "$msg" || true
        git push origin main
        home-manager switch --flake ~/NixOS
      '';

      nixhypr = ''
        wipe
        nixhome
        hyprctl reload
        hyprctl configerrors
      '';

      nixclean = ''
        wipe
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
      '';

      nixdev = ''
        wipe
        nix develop
      '';

      y = "yazi";
      yz = "yazi-noir";
      fm = "yazi-noir";

      gaming = "~/NixOS/Scripts/gaming.sh";
      ungaming = "~/NixOS/Scripts/rice-restore.sh";
    };
  };

  home.stateVersion = "26.11";
}
