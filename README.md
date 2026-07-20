# ILoveNixOS

My NixOS + Home Manager setup, built around Hyprland. Sharing it in case any of it is useful to someone else.

## Installation

You'll need NixOS with flakes enabled. If flakes aren't on yet:

```bash
sudo nano /etc/nixos/configuration.nix
```

add

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

and rebuild once with `sudo nixos-rebuild switch` so the flake commands below work.

Clone it:

```bash
git clone https://github.com/naxce/ILoveNixOS.git ~/NixOS
cd ~/NixOS
```

Before applying it on a different machine, go through these:

- `hardware-configuration.nix` — regenerate with `sudo nixos-generate-config` on the new machine
- `Modules/system/users.nix` — change the username if it's not `naxce`
- `Config/hypr/monitors.conf` — set your own monitor names/resolutions (run `hyprctl monitors` after the first boot to see the real output names)
- `Pictures/wallpapers/avatar.png` — swap in your own picture, same filename

Then apply the system config:

```bash
sudo nixos-rebuild switch --flake ~/NixOS#naxce
```

and Home Manager:

```bash
home-manager switch --flake ~/NixOS#naxce
```

Reboot, and you should land on the login screen, then Hyprland.

If Home Manager complains about existing dotfiles it doesn't want to overwrite:

```bash
home-manager switch --flake ~/NixOS#naxce -b backup
```

## Keybindings

`$mod` is Super.

Run `hotkeys` in any terminal, or press `$mod + F1`, for an interactive fzf menu with every shortcut grouped by app (Hyprland, Hyprswitch, Waybar, Neovim, Kitty, Rofi/Wlogout, Zsh). The tables below are just a quick reference for Hyprland itself.

**Apps**

| Keybind | Action |
| --- | --- |
| `$mod + Return` | Terminal |
| `$mod + Space` | App launcher |
| `$mod + Tab` | Window list |
| `Alt + Tab` | Cycle focus (hold Alt, tap Tab) |
| `$mod + B` | Firefox |
| `$mod + E` | File manager |
| `$mod + Q` | Close window |
| `$mod + Shift + Q` | Exit Hyprland |

**Windows**

| Keybind | Action |
| --- | --- |
| `$mod + F2` | Toggle floating |
| `$mod + F` | Fullscreen |
| `$mod + Shift + F` | Fullscreen, fake (keeps tiling layout) |
| `$mod + J` | Toggle split direction |
| `$mod + P` | Pseudo-tile |
| `$mod + M` | Minimize |
| `` $mod + ` `` | Show/hide minimized windows |
| `$mod + arrows` | Move focus |
| `$mod + Shift + arrows` | Move window |
| `$mod + Ctrl + arrows` | Resize window |

**Workspaces**

| Keybind | Action |
| --- | --- |
| `$mod + [1-0]` | Go to workspace |
| `$mod + Shift + [1-0]` | Move window to workspace |
| `$mod + Ctrl + arrow` | Next/previous workspace |
| `$mod + scroll` | Cycle workspaces |
| 3-finger swipe | Switch workspaces |

**System**

| Keybind | Action |
| --- | --- |
| `$mod + L` | Lock screen |
| `$mod + Shift + L` | Power menu |
| `$mod + N` | Notification center |
| `$mod + V` | Clipboard history |
| `$mod + C` | Color picker |
| `Print` | Screenshot region → swappy |
| `Shift + Print` | Screenshot full screen → swappy |
| `$mod + Print` | Screenshot region → clipboard |

## License

MIT, see [LICENSE](LICENSE).
