# Waybar — Obsidian Glass · KDE Plasma + NixOS

## Pliki
| Plik          | Opis                                              |
|---------------|---------------------------------------------------|
| `config`      | Konfiguracja modułów (KDE-native)                 |
| `style.css`   | Styl GTK CSS (bez filtrów/transformacji)          |
| `waybar.nix`  | Moduł NixOS — instalacja + autostart              |

---

## Instalacja

```bash
# 1. Skopiuj pliki do swojego repozytorium
cp config style.css waybar.nix ~/NixOS/Modules/desktop/waybar/

# 2. W configuration.nix lub głównym module dodaj:
imports = [ ./Modules/desktop/waybar/waybar.nix ];

# 3. Przebuduj
sudo nixos-rebuild switch --flake .#naxce
```

---

## Codzienne użycie

### Waybar startuje automatycznie
Po przebudowie plik `.desktop` ląduje w `/etc/xdg/autostart/` —
KDE Plasma uruchomi waybar przy każdym logowaniu.

### Przeładuj po zmianie configa
```bash
pkill waybar && waybar &
# lub szybciej:
systemctl --user restart waybar   # jeśli przez systemd
```

### Wirtualne pulpity (KWin)
Scroll kółkiem na bloku z kanji = zmiana pulpitu.
Klik = następny pulpit.
Skróty KDE działają normalnie (Ctrl+F1/F2...).

### Moduły — co klikać
| Moduł        | Lewy klik            | Prawy klik / scroll       |
|--------------|----------------------|---------------------------|
| Logo         | Rofi launcher        | —                         |
| CPU / RAM    | btop w terminalu     | —                         |
| Głośność     | pavucontrol          | Wycisz/odcisz             |
| Jasność      | —                    | Scroll = +/- jasność      |
| Sieć         | Ustawienia KDE sieci | —                         |
| Zegar        | Data/godzina         | Tryb kalendarza           |
| Power ⏻      | Menu wylogowania KDE | —                         |

### Bez laptopa?
Usuń z `modules-right` w config:
- `"backlight"` z grupy media
- `"battery"` z grupy status

---

## Kolory
Paleta **Catppuccin Mocha**. Edytuj zmienne `@define-color` na górze `style.css`.
