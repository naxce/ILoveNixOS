# ❄️ ILoveNixOS

This repository contains my full NixOS + Home Manager configuration.

Follow this guide to install and apply it on your system.

---

## ⚠️ Requirements

Before starting:

- NixOS installed
- Flakes enabled
- Git installed
- Internet connection

---

## 1. Enable flakes (if not enabled)

Edit:

```bash
sudo nano /etc/nixos/configuration.nix
```

Add:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

---

## 2. Clone repository

```bash
git clone https://github.com/naxce/ILoveNixOS.git ~/NixOS
cd ~/NixOS
```

---

## 3. Check flake

Make sure `flake.nix` exists:

```bash
ls
```

You should see:

- flake.nix
- configuration files
- home-manager config

---

## 4. Apply system configuration

Replace `naxce` with your hostname if needed:

```bash
sudo nixos-rebuild switch --flake ~/NixOS#naxce
```

---

## 5. Apply Home Manager config

```bash
home-manager switch --flake ~/NixOS#naxce
```

---

## 6. Troubleshooting

### Command not found

Run:

```bash
source ~/.bashrc
```

or restart terminal.

---

### Flake error

Update flake:

```bash
nix flake update
```

---

### Home Manager fails

Try:

```bash
home-manager switch --flake ~/NixOS#naxce -b backup
```

---

## DONE

System should now fully reflect this configuration.

If something breaks → rebuild from flake again.
