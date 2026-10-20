# SylFiles as the only file manager

Date: 2026-10-20

## Intent

SylFiles (Sylvaris) is the only file manager on this system. Inside Neovim, the existing explorers (Oil, Neo-tree) stay. Nothing else: no Yazi, Nemo, Nautilus, Dolphin, or traces of them in the repo or in `$HOME`.

Every "Open File" / "Save As" dialog from any app must open the SylFiles chooser instead of the stock GTK dialog.

## Goals

1. Remove every reference to Yazi and other file managers from the repo.
2. Delete leftover state of other file managers from `$HOME`.
3. Make portal-based file dialogs open SylFiles in the Hyprland session.

## Non-goals

- No change to Sylvaris itself. Its side is already in place: `programs.sylvaris.fileChooser.enable = true` installs `xdg-desktop-portal-termfilechooser`, sets `org.freedesktop.impl.portal.FileChooser=termfilechooser` in `hyprland-portals.conf`, and writes `/etc/xdg/xdg-desktop-portal-termfilechooser/config` with `cmd=.../sylvaris choose`.
- No switch to UWSM; the Sylvaris greeter keeps launching `start-hyprland`.
- No new Neovim plugins or keymaps.
- Sway and niri sessions are out of scope for the dialog fix (niri ships its own session target; Sway is not the daily session).

## Anti-goals

- Any file manager other than SylFiles, Oil, or Neo-tree remains reachable after the change.
- Removing `xdg-desktop-portal-gtk` or `xdg-desktop-portal-termfilechooser`. GTK serves other portal interfaces (Access, Notification, etc.), and termfilechooser is how Sylvaris plugs into the portal. Neither is a file manager.

## Root cause of the dialog bug

`xdg-desktop-portal.service` has `Requisite=graphical-session.target`. In the Hyprland session, nothing starts `graphical-session.target` (no UWSM, no session target), so it stays `inactive`. Every D-Bus activation of the portal fails with:

```
Dependency failed for Portal service.
```

With no portal running, GTK falls back to its built-in `GtkFileChooserDialog` (the screenshot). Portal routing and the Sylvaris chooser are already configured correctly. They are just never reached.

## Design

### 1. Session target (fix)

In `Modules/desktop/hyprland.nix`, add a user target that pulls in `graphical-session.target`:

```nix
systemd.user.targets.hyprland-session = {
  description = "Hyprland compositor session";
  bindsTo = [ "graphical-session.target" ];
  wants = [ "graphical-session-pre.target" ];
  after = [ "graphical-session-pre.target" ];
};
```

In `Config/hypr/autostart.lua`, replace the standalone `dbus-update-activation-environment --systemd --all` entry with one sequential command. This lets the portal start with `WAYLAND_DISPLAY` and the related variables already imported:

```
sh -c 'dbus-update-activation-environment --systemd --all && systemctl --user start hyprland-session.target'
```

`hl.exec_cmd` entries run concurrently, so the two steps must live in one `sh -c`.

### 2. Repo cleanup

| File | Change |
|---|---|
| `Config/yazi/` | delete directory |
| `Config/nvim/lua/plugins/yazi.lua` | delete file |
| `Config/nvim/lua/plugins/ui.lua` | remove dashboard button `y  Otwórz Yazi` |
| `home.nix` | remove `yy()` function from zsh init; remove aliases `y` and `yz` |
| `Config/hypr/windowrules.lua` | remove `opacity-yazi` rule |
| `Config/niri/config.kdl` | remove `yazi-fm` window-rule block |
| `Scripts/hotkeys.sh` | remove dashboard `y` line, whole `yazi_binds()` function, `y`/`yz`/`yy` lines under Files, `"Yazi"` menu entry and its `case` arm |

Oil (`-`) and Neo-tree (`:Neotree toggle`, dashboard `e`) already cover the old `<leader>-` / `<leader>cw` use. Those keys are just dropped.

After the edits, `grep -rniI "yazi\|nemo\|nautilus\|dolphin\|thunar" --exclude-dir=.git .` must return nothing, except `Config/gimp/` files, which match unrelated words.

### 3. `$HOME` cleanup (approved by user; irreversible)

Delete:

- `~/.config/yazi`, `~/.config/nemo`, `~/.config/nautilus`
- `~/.config/dolphinrc.backup`, `~/.config/mimeapps.list.backup.old`
- `~/.local/share/dolphin`, `~/.local/share/nautilus`, `~/.local/share/nemo`
- `~/.local/state/yazi`, `~/.local/state/dolphinstaterc`, `~/.local/state/UserFeedback.org.kde.dolphin`
- `~/.local/share/nvim/lazy/yazi.nvim`

Delete these only after the rebuild, so nothing recreates them. List each path right before deleting it.

## Validation

1. `nixtest` passes (flake check, `nixos-rebuild test`, `home-manager build`, `hyprctl configerrors` clean).
2. Apply home config (`nixup` or the user's normal path), then run `systemctl --user start hyprland-session.target` in the live session:
   - `systemctl --user is-active graphical-session.target xdg-desktop-portal` → both `active`.
   - `journalctl --user -u xdg-desktop-portal -b` shows no new `Dependency failed`.
3. Trigger a real dialog:
   ```
   gdbus call --session --dest org.freedesktop.portal.Desktop \
     --object-path /org/freedesktop/portal/desktop \
     --method org.freedesktop.portal.FileChooser.OpenFile "" "Test" {}
   ```
   `hyprctl clients` shows `org.quickshell` with title `Open a file — SylFiles`. Then confirm from a real app (Firefox "Open File", GIMP).
4. The user confirms that a fresh login brings the portal up with no manual step. Logout and reboot are the user's call.
5. The grep in §2 is empty, and the `$HOME` paths in §3 are gone.

## Builder calls (not user decisions)

- Oil and Neo-tree replace Yazi in Neovim; no new keymaps.
- The target is defined in NixOS (`systemd.user.targets`) inside the existing Hyprland module, not via home-manager.
- `fm = "sylvaris files open ."` alias and `Mod+E` binds stay as they are.

## Risks

- After logout, `hyprland-session.target` may stay active in the lingering user manager, and the portal keeps the old `WAYLAND_DISPLAY` until the next login re-imports the environment. If the next login shows a broken portal, add an explicit stop on compositor exit.
- `~/.config/yazi/theme.toml` was a symlink into `Config/yazi/`. No repo or Sylvaris script references it today. If a theme switcher recreates it, that switcher is the next thing to clean.
