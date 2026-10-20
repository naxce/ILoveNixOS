# SylFiles Only Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Portal file dialogs open SylFiles in Hyprland, and every trace of Yazi, Nemo, Nautilus, and Dolphin is gone from the repo and `$HOME`.

**Architecture:** A NixOS-defined user `hyprland-session.target` binds `graphical-session.target`. Hyprland autostart starts it after importing the environment, which unblocks `xdg-desktop-portal` (`Requisite=graphical-session.target`). Cleanup is pure deletion across config files, followed by deletion of leftover state in `$HOME`.

**Tech Stack:** NixOS flake + home-manager, Hyprland Lua config, niri KDL, Neovim lazy.nvim, zsh, xdg-desktop-portal + termfilechooser (Sylvaris).

**Spec:** `docs/superpowers/specs/2026-10-20-sylfiles-only-design.md`

## Global Constraints

- Never add comments to code. Remove any comment found in a touched file.
- Do not commit, revert, reset, stash, reboot, garbage-collect, or remove generations. The `nixall`/`nixos`/`nixup` aliases run `git commit` + `git push`, so do not use them. Apply with `nixtest` (system, via `nixos-rebuild test`) and `home-manager switch --flake ~/NixOS` (home).
- `nixtest` currently exits non-zero because of an existing failure: `systemd-fsck@dev-disk-by\x2duuid-E818049F18046EBE.service` (NTFS `Metadata kept in Windows cache`). This failure does not block the plan. Any other failed unit does.
- Keep `xdg-desktop-portal-gtk`, `xdg-desktop-portal-termfilechooser`, `programs.sylvaris.fileChooser.enable`, the `fm` alias, and the `Mod+E` binds.
- No UWSM. No new nvim plugins or keymaps.
- Preserve the existing `M result` change in the working tree.

## Review Focus

- Second login, without a reboot: the target may still be active with stale env. Expectation: the portal works after logout and login. Task 1 Step 6 asks the user to check this.
- App launched before autostart finishes: the portal is D-Bus-activated on first use, so a dialog opened late still works. Covered by Task 1 Step 5, which runs after login.
- Save dialog, not only Open: `Save as — SylFiles` should appear. Task 1 Step 5 includes `SaveFile`.
- Directories opened from GUI apps (`inode/directory`) still go to `sylvaris-files.desktop` after cleanup. Task 2 Step 5 checks this.
- Neovim starts cleanly with no yazi plugin or button errors. Task 2 Step 4 checks this.

---

### Task 1: Start graphical-session.target in Hyprland

**Files:**
- Modify: `Modules/desktop/hyprland.nix` (add `systemd.user.targets.hyprland-session` after the `xdg.portal` block)
- Modify: `Config/hypr/autostart.lua:6`

**Interfaces:**
- Produces: user unit `hyprland-session.target` (`BindsTo=graphical-session.target`, `Wants`/`After=graphical-session-pre.target`).

- [ ] **Step 1: Record failing state**

Run: `systemctl --user is-active graphical-session.target xdg-desktop-portal`
Expected: `inactive` twice. `journalctl --user -u xdg-desktop-portal -b | tail -2` shows `Dependency failed for Portal service.`

- [ ] **Step 2: Add the target to `Modules/desktop/hyprland.nix`**

```nix
  systemd.user.targets.hyprland-session = {
    description = "Hyprland compositor session";
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
```

- [ ] **Step 3: Replace line 6 of `Config/hypr/autostart.lua`**

Replace `"dbus-update-activation-environment --systemd --all",` with:

```lua
        "sh -c 'dbus-update-activation-environment --systemd --all && systemctl --user start hyprland-session.target'",
```

- [ ] **Step 4: Build and activate**

Run: `nixtest`, then `home-manager switch --flake ~/NixOS`
Expected: flake check passes, and `hyprctl configerrors` is empty. The only failed unit is the known NTFS fsck one. `systemctl --user cat hyprland-session.target` shows `BindsTo=graphical-session.target`.

- [ ] **Step 5: Verify live**

Run:
```
dbus-update-activation-environment --systemd --all && systemctl --user start hyprland-session.target
systemctl --user is-active graphical-session.target xdg-desktop-portal
gdbus call --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop --method org.freedesktop.portal.FileChooser.OpenFile "" "Test" {}
hyprctl clients | grep -A3 "SylFiles"
```
Expected: `active` twice, and a client `org.quickshell` with title `Open a file — SylFiles`. Close it. Repeat with `--method org.freedesktop.portal.FileChooser.SaveFile` and expect `Save as — SylFiles`. Then open the "Open File" dialog in Firefox and confirm it is SylFiles, not the GTK dialog.

- [ ] **Step 6: Hand the fresh-login check to the user**

Ask the user to log out and back in (their call), then rerun the Step 5 `is-active` + `gdbus` checks. If the portal fails on the second login, report it as the stale-target risk from the spec and do not improvise a fix.

### Task 2: Remove Yazi from the repo

**Files:**
- Delete: `Config/yazi/`, `Config/nvim/lua/plugins/yazi.lua`
- Modify: `Config/nvim/lua/plugins/ui.lua:125` (drop the `dashboard.button("y", ...)` line)
- Modify: `home.nix:359-366` (`yy()` function), `home.nix:537-538` (`y`, `yz` aliases)
- Modify: `Config/hypr/windowrules.lua:54-59` (`opacity-yazi` rule block)
- Modify: `Config/niri/config.kdl:125-128` (`yazi-fm` window-rule block)
- Modify: `Scripts/hotkeys.sh`: line `y	Open Yazi` in the dashboard section, the whole `yazi_binds()` function, the `y`/`yz`/`yy` lines under `── Files ──`, the `"Yazi" \` menu entry, and the `"Yazi")` case arm

- [ ] **Step 1: Confirm references exist**

Run: `grep -rniIl "yazi\|nemo\|nautilus\|dolphin\|thunar" --exclude-dir=.git --exclude-dir=docs . | grep -v Config/gimp`
Expected: the files listed above.

- [ ] **Step 2: Make the deletions and edits listed under Files**

Keep blank-line spacing consistent with the surrounding code (one blank line between window-rule blocks and between shell functions).

- [ ] **Step 3: Grep is clean**

Run: the Step 1 command
Expected: no output.

- [ ] **Step 4: Validate**

Run: `nixtest`, then `home-manager switch --flake ~/NixOS`, then `nvim --headless "+Lazy! clean" +qa` and `nvim --headless +qa 2>&1`
Expected: same pass criteria as Task 1 Step 4. Both nvim commands print no errors, `~/.local/share/nvim/lazy/yazi.nvim` has been removed by `Lazy clean`, and `hotkeys` still opens with no "Yazi" category. Check the hotkeys script with `bash -n Scripts/hotkeys.sh`, which should exit 0.

- [ ] **Step 5: Directory handler unchanged**

Run: `xdg-mime query default inode/directory`
Expected: `sylvaris-files.desktop`

### Task 3: Delete leftover file-manager state from `$HOME`

**Files:** none in repo.

**Interfaces:**
- Consumes: Tasks 1–2 activated, so home-manager no longer manages anything under these paths.

- [ ] **Step 1: List targets**

Run:
```
ls -ld ~/.config/yazi ~/.config/nemo ~/.config/nautilus ~/.config/dolphinrc.backup ~/.config/mimeapps.list.backup.old ~/.local/share/dolphin ~/.local/share/nautilus ~/.local/share/nemo ~/.local/state/yazi ~/.local/state/dolphinstaterc ~/.local/state/UserFeedback.org.kde.dolphin ~/.local/share/nvim/lazy/yazi.nvim
```
Expected: each path exists, except `yazi.nvim` if Task 2 already removed it. None is a symlink into `/nix/store`. Stop and report if one is.

- [ ] **Step 2: Delete them**

Run: `rm -rf` with exactly the paths from Step 1 (user approved, irreversible).

- [ ] **Step 3: Verify**

Run: `ls -d ~/.config/* ~/.local/share/* ~/.local/state/* | grep -iE "yazi|nemo|nautilus|dolphin|thunar"`
Expected: no output.

### Final check

- [ ] Report to the user: the spec §Validation items 1, 2, 3, and 5, with the command output. Item 4 (fresh login) is pending on the user. List `git status --short` and leave everything uncommitted.
