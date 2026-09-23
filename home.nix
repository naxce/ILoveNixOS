{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "naxce";
  home.homeDirectory = "/home/naxce";
  programs.home-manager.enable = true;
  home.preferXdgDirectories = true;

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 15;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.sessionVariables = {
    GTK_THEME = "adw-gtk3-dark";
  };

  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
  '';
  xdg.configFile."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
  '';

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      sansSerif = [ "Inter" ];
      serif = [ "Inter" ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "JetBrains Mono"
      ];
      emoji = [ "Twemoji Color Emoji" ];
    };
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
        --config "$HOME/.config/kitty/work.conf" \
        "$@"
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
    '')
  ];

  home.file.".config/cava/shaders".source = ./Config/cava/shaders;
  home.file.".config/cava/themes".source = ./Config/cava/themes;
  home.file.".config/kitty/kitty.conf".source = ./Config/kitty/kitty.conf;
  home.file.".config/kitty/work.conf".source = ./Config/kitty/work.conf;
  home.file.".config/kitty/sys_info.sh".source = ./Config/kitty/sys_info.sh;
  home.file.".config/kitty/weather.sh".source = ./Config/kitty/weather.sh;
  home.file.".config/kitty/themes".source = ./Config/kitty/themes;
  home.file.".config/nvim".source = ./Config/nvim;
  home.file.".config/hypr/autostart.lua".source = ./Config/hypr/autostart.lua;
  home.file.".config/hypr/binds.lua".source = ./Config/hypr/binds.lua;
  home.file.".config/hypr/canvas.lua".source = ./Config/hypr/canvas.lua;
  home.file.".config/hypr/hyprland.lua".source = ./Config/hypr/hyprland.lua;
  home.file.".config/hypr/input.lua".source = ./Config/hypr/input.lua;
  home.file.".config/hypr/monitors.lua".source = ./Config/hypr/monitors.lua;
  home.file.".config/hypr/windowrules.lua".source = ./Config/hypr/windowrules.lua;

  home.file.".config/hypr/hypridle.conf".source = ./Config/hypr/hypridle.conf;

  home.activation.hyprLocalOverrides = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    localDir="$HOME/.config/hypr/local"
    $DRY_RUN_CMD mkdir -p "$localDir"
    for f in monitors.lua looknfeel.lua input.lua gaming.lua; do
      if [ ! -e "$localDir/$f" ]; then
        $DRY_RUN_CMD touch "$localDir/$f"
      fi
    done
  '';

  home.file.".config/waybar/config-sway.jsonc".source = ./Config/waybar/config-sway.jsonc;
  home.file.".config/waybar/config-niri.jsonc".source = ./Config/waybar/config-niri.jsonc;

  home.file.".config/niri/config.kdl".source = ./Config/niri/config.kdl;
  home.file.".config/rofi/config.rasi".source = ./Config/rofi/config.rasi;
  home.file.".config/swaync/config.json".source = ./Config/swaync/config.json;
  home.file.".config/wlogout/layout".source = ./Config/wlogout/layout;
  home.file.".config/swappy".source = ./Config/swappy;
  home.file.".config/yazi/yazi.toml".source = ./Config/yazi/yazi.toml;
  home.file.".config/yazi/keymap.toml".source = ./Config/yazi/keymap.toml;

  home.file.".config/GIMP".source = ./Config/gimp;

  home.file.".config/sway".source = ./Config/sway;

  home.file.".config/MangoHud".source = ./Config/mangohud;

  home.activation.applyTheme = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD ${pkgs.bash}/bin/bash "$HOME/NixOS/Scripts/apply-theme.sh" || true
  '';

  home.file."Pictures/wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/NixOS/Pictures/wallpapers";
  home.file."Pictures/Screenshots/.keep".text = "";

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
      fastfetch --config "$HOME/.config/fastfetch/work.jsonc" 2>/dev/null

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

      wipe = ''reset && fastfetch --config "$HOME/.config/fastfetch/work.jsonc"'';

      cmatrix = "cmatrix -C white";

      nixall = ''
        wipe
        cd ~/NixOS || exit
        nix flake update
        msg="$*"; [ -n "$msg" ] || msg="Update Commit"
        git add .
        git commit -m "$msg" || true
        git pull --rebase origin main
        git push origin main
        sudo nixos-rebuild switch --flake .
        home-manager switch --flake ~/NixOS
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
        hyprctl reload
        hyprctl configerrors
        swaymsg reload
      '';

      nixtest = ''
        wipe
        cd ~/NixOS || exit
        nix flake check
        nixos-rebuild test --flake .
        home-manager build --flake ~/NixOS
        hyprctl configerrors
      '';

      nixos = ''
        wipe
        cd ~/NixOS || exit
        msg="$*"; [ -n "$msg" ] || msg="Update Commit"
        git add .
        git commit -m "$msg" || true
        git pull --rebase origin main
        git push origin main
        sudo nixos-rebuild switch --flake .
      '';

      nixup = ''
        wipe
        cd ~/NixOS || exit
        nix flake update
        msg="$*"; [ -n "$msg" ] || msg="Update Commit"
        git add .
        git commit -m "$msg" || true
        git pull --rebase origin main
        git push origin main
        sudo nixos-rebuild switch --flake .
      '';

      nixbuild = ''
        wipe
        cd ~/NixOS || exit
        sudo nixos-rebuild switch --flake .
      '';

      nixhome = ''
        wipe
        cd ~/NixOS || exit
        msg="$*"; [ -n "$msg" ] || msg="Update Commit"
        git add .
        git commit -m "$msg" || true
        git pull --rebase origin main
        git push origin main
        home-manager switch --flake ~/NixOS
      '';

      ap = ''
        wipe
        bluetoothctl connect 74:3F:8E:90:8E:4B
      '';

      hl = ''
        wipe
        start-hyprland
      '';

      wdr = ''
        wipe
        sudo systemctl restart waydroid-container
        waydroid session start
      '';

      wdrui = ''
        wipe
        waydroid show-full-ui
      '';

      sw = ''
        wipe
        sway
      '';

      nr = ''
        wipe
        niri
      '';

      nixhypr = ''
        wipe
        nixhome
        hyprctl reload
        hyprctl configerrors
      '';

      nixsway = ''
        wipe
        nixhome
        swaymsg reload
      '';

      nixniri = ''
        wipe
        nixhome
        niri-cli validate
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

      niritest = ''
        wipe
        niri-cli validate -c ~/NixOS/Config/niri/config.kdl
      '';

      niriout = "niri-cli msg outputs";
      niriws = "niri-cli msg workspaces";
      niriwin = "niri-cli msg windows";
      nirikeys = "niri-cli msg keyboard-layouts";

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

  home.stateVersion = "26.11";
}
