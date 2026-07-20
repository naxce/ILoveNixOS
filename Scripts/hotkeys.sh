#!/usr/bin/env bash
# Interactive keybindings cheat-sheet.
# Run "hotkeys" in any terminal, or press Super + F1, to open a category
# menu (fzf), then browse all shortcuts for the chosen app.
#
# All hotkeys use "Super" to refer to the key with the Windows/logo icon.

set -euo pipefail

FZF_NOIR=(
  --color=fg:#e8e8e8,bg:#000000,hl:#ffffff
  --color=fg+:#ffffff,bg+:#1a1a1a,hl+:#ffffff
  --color=border:#4d4d4d,prompt:#ffffff,pointer:#ffffff
  --color=info:#8a8a8a,marker:#ffffff,spinner:#8a8a8a,header:#8a8a8a
  --border=rounded
  --height=90%
  --layout=reverse
)

# ---------------------------------------------------------------------------
# Category content. Each block is "key<TAB>action" so fzf can column-align it.
# ---------------------------------------------------------------------------

hyprland_binds() {
  cat <<'EOF'
── Apps & session ──	
Super + Return	Open terminal (kitty)
Super + Space	App launcher (rofi drun)
Super + Tab	Window switcher (rofi window list)
Super + E	Open file manager (Yazi)
Super + B	Open Firefox
Super + F1	Open this keybindings menu
Super + L	Lock screen
Super + Shift + L	Power menu (wlogout)
Super + Shift + Q	Exit Hyprland
── Window management ──	
Super + Q	Close active window
Super + F2	Toggle floating
Super + F	Toggle fullscreen
Super + Shift + F	Fullscreen (fake, keeps bar/gaps)
Super + P	Toggle pseudo-tiling
Super + J	Toggle split direction (horizontal/vertical)
Super + M	Send window to the minimized workspace
Super + Shift + M	Show/hide the minimized workspace
Super + `	Show/hide the minimized workspace (grave key, alt to above)
── Focus & movement ──	
Super + Left/Right/Up/Down	Move focus between windows
Super + Shift + Left/Right/Up/Down	Move active window in that direction
Super + Ctrl + Left/Right/Up/Down	Resize active window
Super + Left click + drag	Move window
Super + Right click + drag	Resize window
── Workspaces ──	
Super + 1..0	Go to workspace 1-10
Super + Shift + 1..0	Move active window to workspace 1-10
Super + Ctrl + Left/Right	Go to previous/next workspace
Super + Mouse wheel	Scroll through workspaces
── Screenshots & tools ──	
Print	Screenshot a selected region, opens in Swappy to edit
Shift + Print	Screenshot the full screen, opens in Swappy to edit
Super + Print	Screenshot a selected region, copies straight to clipboard
Super + C	Pick a color from the screen (hyprpicker)
Super + N	Toggle notification center (swaync)
Super + V	Open clipboard history (cliphist + rofi)
── Media & hardware keys ──	
XF86AudioRaiseVolume	Volume up 5%
XF86AudioLowerVolume	Volume down 5%
XF86AudioMute	Toggle mute
XF86AudioPlay	Play / pause media
XF86AudioNext	Next media track
XF86AudioPrev	Previous media track
XF86MonBrightnessUp	Brightness up 5%
XF86MonBrightnessDown	Brightness down 5%
EOF
}

hyprswitch_binds() {
  cat <<'EOF'
Alt + Tab	Open window switcher, hold Alt and press Tab to cycle forward
Alt + Shift + Tab	Cycle backward through windows
Release Alt	Confirm selection and switch to window
EOF
}

waybar_binds() {
  cat <<'EOF'
── Workspaces & window ──	
Click workspace	Jump to that workspace
Click minimized indicator	Show/hide the minimized workspace
Click clock/window module	Display only, no action
── System tray ──	
Click network icon	Open nm-connection-editor
Click bluetooth icon	Open blueman-manager
Click volume icon	Toggle mute
Scroll up on volume icon	Volume up 5%
Scroll down on volume icon	Volume down 5%
Click notification icon	Toggle notification center (swaync)
Click power icon	Open wlogout
EOF
}

neovim_binds() {
  cat <<'EOF'
Note:	Leader key is Space
── Basics & editing ──	
jk (insert mode)	Escape to normal mode
Esc	Clear search highlight
x	Delete character without yanking it
< / > (visual)	Indent left/right, keep selection active
J (visual)	Move selected lines down
K (visual)	Move selected lines up
p (visual)	Paste without overwriting the register
gcc	Comment/uncomment the current line
gc (normal/visual)	Comment/uncomment the selection
Leader + w	Save file
Leader + q	Close window
Leader + Q	Quit without saving
q (in help/quickfix windows)	Close that window
── Navigation & search ──	
n / N	Next/previous search result, keep centered
Ctrl + d / Ctrl + u	Scroll half page down/up, keep centered
s (normal/visual/operator)	Flash: jump to any visible location
Shift + S	Flash: jump via treesitter node
Leader + ff	Find file (Telescope)
Leader + fg	Live grep across the project
Leader + fw	Grep the word under the cursor
Leader + fb	List open buffers
Leader + fh	Search Neovim help
Leader + fr	Recently opened files
Leader + fc	Browse git commits
Leader + fs	Git status
Leader + fd	Diagnostics for the whole project
Leader + fk	List all keymaps
Leader + fp	Resume the last search
Leader + /	Fuzzy search inside current buffer
── Splits, buffers & terminal ──	
Ctrl + h/j/k/l	Move focus between splits
Ctrl + Up/Down	Resize split height
Ctrl + Left/Right	Resize split width
Shift + H	Previous buffer
Shift + L	Next buffer
Leader + bd	Close current buffer
Leader + tt	Open terminal in a bottom split
Esc Esc (terminal mode)	Exit terminal insert mode
── File tree & quick file access ──	
-	Open parent directory (Oil)
Leader + ee	Toggle the file tree panel (Neo-tree)
Leader + ef	Reveal current file in the file tree
Leader + eg	Show git status in the file tree
Leader + ha	Harpoon: add current file
Leader + hh	Harpoon: toggle quick menu
Leader + 1..4	Harpoon: jump to file 1-4
Ctrl + Shift + P	Harpoon: previous file
Ctrl + Shift + N	Harpoon: next file
── Code intelligence (LSP) ──	
gd	Go to definition
gD	Go to declaration
gr	Show references (Telescope)
gI	Go to implementation
gy	Go to type definition
K	Show hover documentation
Ctrl + k (insert)	Show signature help
Leader + rn	Rename symbol
Leader + ca	Code action
Leader + ds	Document symbols
Leader + ws	Workspace symbols
Leader + th	Toggle inlay hints
Leader + cf	Format the file
── Diagnostics (Trouble) ──	
[d / ]d	Previous/next diagnostic
Leader + e	Show diagnostic in a floating window
Leader + xl	Send diagnostics to the location list
Leader + xx	Whole project diagnostics
Leader + xd	Current file diagnostics
Leader + xq	Quickfix list
Leader + xr	References
Leader + xs	Symbols in file
Leader + ft	Find TODOs in the project
── Git ──	
]h / [h	Next/previous git hunk
Leader + hs	Stage git hunk
Leader + hr	Reset git hunk
Leader + hp	Preview git hunk
Leader + hb	Show git blame for the line
Leader + hd	Git diff against HEAD
Leader + gg	Open LazyGit
Leader + gd	Diffview: show changes
Leader + gh	Diffview: file history
Leader + u	Toggle Undotree
── Misc ──	
Leader + ?	Show all buffer keymaps (which-key)
Leader + ls	LiveServer: start (pick path and port)
Leader + lo	LiveServer: open existing port in browser
Leader + lr	LiveServer: force reload
Leader + lt	LiveServer: toggle live-reload
Leader + li	LiveServer: show status
Leader + lS	LiveServer: stop one server
Leader + lA	LiveServer: stop all servers
Leader + mps	Markdown: start live preview in browser
Leader + mpr	Markdown: force refresh preview
Leader + mpS	Markdown: stop preview
── Start screen (Alpha dashboard) ──	
f	Find file
g	Grep in project
r	Recent files
e	Toggle file tree
y	Open Yazi
l	Open Lazy (plugin manager)
q	Quit
EOF
}

yazi_binds() {
  cat <<'EOF'
Note:	Custom keys shown here on top of Yazi's own defaults (arrows, hjkl, etc.)
── Navigation ──	
<Right> / l	Open file or enter directory
<Left> / h	Go to parent directory
── Go to (press g, then...) ──	
g n	Go to ~/NixOS
g d	Go to ~/Downloads
g p	Go to ~/Pictures
g c	Go to ~/.config
── Open & copy ──	
m	Menu / open with
O	Open with (interactive)
c p	Copy full path
c f	Copy filename
c n	Copy filename without extension
── Archives (via ouch) ──	
C	Compress selection to .tar.gz
E	Extract selected archive(s)
L	List contents of an archive
── Misc ──	
!	Open a shell in the current directory
?	Help (all keymaps)
Esc (in prompt)	Cancel
Enter (in prompt)	Confirm
── Yazi inside Neovim (yazi.nvim) ──	
Leader + -	Open Yazi in the current file's directory
Leader + cw	Open Yazi in Neovim's working directory
Ctrl + Up	Resume the last Yazi session
F1 (inside Yazi popup)	Show help
Ctrl + v (inside Yazi popup)	Open file in vertical split
Ctrl + x (inside Yazi popup)	Open file in horizontal split
Ctrl + t (inside Yazi popup)	Open file in a new tab
Ctrl + s (inside Yazi popup)	Grep in directory
Ctrl + g (inside Yazi popup)	Replace in directory
Tab (inside Yazi popup)	Cycle open Neovim buffers
Ctrl + y (inside Yazi popup)	Copy relative path of selected files
EOF
}

kitty_binds() {
  cat <<'EOF'
Note:	Built-in kitty defaults, no custom "map" overrides in kitty.conf
── Windows & tabs ──	
Ctrl + Shift + Enter	New window
Ctrl + Shift + W	Close window
Ctrl + Shift + T	New tab
Ctrl + Shift + Q	Close tab
Ctrl + Shift + Right/Left	Next/previous tab
Ctrl + Shift + .	Move tab forward
Ctrl + Shift + ,	Move tab backward
── Font & display ──	
Ctrl + Shift + Equal	Increase font size
Ctrl + Shift + Minus	Decrease font size
Ctrl + Shift + Backspace	Reset font size to default
── Clipboard & search ──	
Ctrl + Shift + F	Search scrollback
Ctrl + Shift + C	Copy to clipboard
Ctrl + Shift + V	Paste from clipboard
── Scrolling ──	
Ctrl + Shift + Up/Down	Scroll line by line
Ctrl + Shift + Page Up/Down	Scroll page by page
Ctrl + Shift + Home/End	Scroll to top/bottom
EOF
}

rofi_wlogout_binds() {
  cat <<'EOF'
── Rofi (launcher / window switcher) ──	
Type to filter	Fuzzy search entries
Up/Down or Ctrl + p/n	Move selection
Enter	Launch the selected entry
Escape	Close rofi
Ctrl + Enter	Launch entry without closing (where supported)
── Wlogout (power menu) ──	
l	Lock
e	Logout
s	Sleep
r	Restart
p	Shut down
Escape	Close the menu
EOF
}

zsh_shell_aliases() {
  cat <<'EOF'
── NixOS / flake management ──	
nixos [msg]	Commit, push and rebuild the NixOS system
nixup [msg]	Update the flake, commit, push and rebuild
nixgit [msg]	Commit and push only, no rebuild
nixbuild	Rebuild the system from the flake
nixhome [msg]	Commit, push and apply home-manager
nixhypr [msg]	Apply home-manager and reload Hyprland
nixclean	Garbage-collect old system generations
nixdev	Enter the flake's dev shell
nixhelp	Show this list of nix* commands
── Gaming mode ──	
gaming	Switch to low-latency gaming mode
ungaming	Restore the full rice (animations, effects)
── File manager (Yazi) ──	
y	Open Yazi in the current terminal
yz / fm	Open Yazi in its own noir-themed kitty window
yy	Open Yazi, then cd into the directory it was closed in
── Editor & git ──	
v / vim	Open Neovim
lg	Open LazyGit
── Listing & viewing files ──	
ls / ll / la / lt	Directory listings (eza)
cat	View a file (bat, plain style, no paging)
── Fun / misc ──	
wipe	Clear the terminal and show fastfetch
cmatrix	Digital rain screensaver (white theme)
── Power ──	
robot	Reboot the system
komasz	Power off the system
israel	Force an immediate reboot (magic SysRq, skips clean shutdown)
── Help ──	
hotkeys	Open this keybindings menu
EOF
}

# ---------------------------------------------------------------------------
# Menu machinery
# ---------------------------------------------------------------------------

require_fzf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for the 'hotkeys' menu but was not found in PATH." >&2
    exit 1
  fi
}

show_category() {
  local title="$1"
  local content="$2"
  local bold=$'\033[1m' reset=$'\033[0m'

  echo -e "$content" \
    | column -t -s $'\t' \
    | sed -E "s/^(── .* ──)[[:space:]]*\$/${bold}\1${reset}/" \
    | fzf --ansi "${FZF_NOIR[@]}" \
      --header="$title  (Esc to go back, Enter/q to close)" \
      --prompt="$title > " \
      --no-info \
      >/dev/null
}

main_menu() {
  local choice
  choice=$(printf '%s\n' \
    "Hyprland" \
    "Hyprswitch" \
    "Waybar" \
    "Neovim" \
    "Yazi" \
    "Kitty" \
    "Rofi & Wlogout" \
    "Zsh shortcuts" \
    "Quit" |
    fzf "${FZF_NOIR[@]}" \
      --header="Keybindings cheat-sheet  (Super = key with the Windows/logo icon)" \
      --prompt="Category > " \
      --no-info)

  case "$choice" in
    "Hyprland") show_category "Hyprland" "$(hyprland_binds)" ;;
    "Hyprswitch") show_category "Hyprswitch" "$(hyprswitch_binds)" ;;
    "Waybar") show_category "Waybar" "$(waybar_binds)" ;;
    "Neovim") show_category "Neovim" "$(neovim_binds)" ;;
    "Yazi") show_category "Yazi" "$(yazi_binds)" ;;
    "Kitty") show_category "Kitty" "$(kitty_binds)" ;;
    "Rofi & Wlogout") show_category "Rofi & Wlogout" "$(rofi_wlogout_binds)" ;;
    "Zsh shortcuts") show_category "Zsh shortcuts" "$(zsh_shell_aliases)" ;;
    "Quit"|"") return 1 ;;
  esac
  return 0
}

require_fzf
while main_menu; do :; done
