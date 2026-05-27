# Waybar Config — Obsidian Glass
## NixOS + KDE Plasma / Hyprland

---

### Pliki
| Plik          | Opis                                        |
|---------------|---------------------------------------------|
| `config`      | Główny config Waybar (JSON)                 |
| `style.css`   | Styl — dark glassmorphism, paleta Catppuccin Mocha |
| `waybar.nix`  | Home-Manager modul, gotowy do importu       |

---

### Instalacja (Home-Manager)

1. Skopiuj wszystkie 3 pliki do `~/.config/nixos/modules/waybar/`
   ```
   ~/.config/nixos/modules/waybar/
   ├── config
   ├── style.css
   └── waybar.nix
   ```

2. W `home.nix` dodaj:
   ```nix
   imports = [ ./modules/waybar/waybar.nix ];
   ```

3. Przebuduj:
   ```bash
   home-manager switch --flake .#twoj-profil
   # lub
   sudo nixos-rebuild switch --flake .#twoja-konfiguracja
   ```

---

### Wymagane czcionki

Zainstaluj `JetBrainsMono Nerd Font` — jest już w `waybar.nix`.
Po przebudowie sprawdź:
```bash
fc-list | grep -i jetbrains
```

---

### Moduły i co robią

| Moduł              | Skrót / Klik                                    |
|--------------------|-------------------------------------------------|
| `custom/logo`      | Otwiera Rofi launcher                           |
| `workspaces`       | Scroll kółkiem = zmiana workspace               |
| `clock`            | Klik = data • Prawy klik = tryb kalendarza      |
| `cpu` / `memory`   | Klik = otwiera btop                             |
| `pulseaudio`       | Klik = pavucontrol • Prawy = wycisz             |
| `backlight`        | Scroll = zmiana jasności                        |
| `mpris`            | Pokazuje odtwarzany utwór                       |
| `network`          | Klik = nm-connection-editor                     |
| `bluetooth`        | Klik = blueberry                                |
| `custom/power`     | Klik = wlogout                                  |

---

### Dostosowanie

**Zmiana kolorów** — edytuj zmienne `@define-color` na górze `style.css`.

**Inne workspace labels** — zmień `format-icons` w sekcji `hyprland/workspaces`
(domyślnie: cyfry kanji 一二三四五).

**Bez laptopa** — usuń moduły `battery` i `backlight` z `modules-right`
oraz ich sekcji konfiguracyjnych.

**Pulseaudio vs Pipewire** — moduł `pulseaudio` działa z oboma.

---

### Estetyka

- Paleta: **Catppuccin Mocha**
- Styl: **Dark glassmorphism** z subtelnym blur + border glow
- Bar unosi się 6px nad krawędzią ekranu z marginesami 12px
- Animacje: pulse dla urgent WS, blink dla krytycznej baterii, glow na hover
