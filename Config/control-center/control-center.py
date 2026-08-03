#!/usr/bin/env python3
"""
control-center — a floating quick-settings panel that slides down from the
waybar clock module.

Layout (three columns inside one popover window):
  left    -> mini calendar + "now playing" (any MPRIS player via playerctl —
             Cider, a browser tab playing YouTube, Spotify, mpv, ...; the
             little tag above the title reflects whichever one is active)
  center  -> big clock + date, the visual anchor of the panel
  right   -> stacked quick-settings rows (Wi-Fi, Bluetooth, Volume, Displays,
             Night Light, Do Not Disturb, Performance) — each row expands
             into its own detail view in place, in the same panel.

The window surface itself covers the whole screen (invisible outside the
panel) so it can catch clicks anywhere, but closes automatically only when
the click lands outside the panel — no visible backdrop, no manual
dismissal.

Design mirrors nixgreet/hyprlock/swaync: pure black translucent panels,
1px hairline borders at 8% white, 10-14px rounding, Inter/JetBrainsMono
Nerd Font, no color accents beyond white/gray.

State that should survive a reboot (last picked monitor layout) is written
straight into ~/.config/hypr/local/monitors.lua, which hyprland.lua
already `require`s — nothing extra to wire up for persistence.
"""

import sys
import traceback

LOG_PATH = "/tmp/control-center.log"


def _log(msg):
    try:
        with open(LOG_PATH, "a") as f:
            f.write(msg + "\n")
    except OSError:
        pass


def _excepthook(exc_type, exc_value, exc_tb):
    _log("".join(traceback.format_exception(exc_type, exc_value, exc_tb)))
    sys.__excepthook__(exc_type, exc_value, exc_tb)


sys.excepthook = _excepthook

try:
    import gi

    gi.require_version("Gtk", "4.0")
    gi.require_version("Gtk4LayerShell", "1.0")

    from gi.repository import Gdk, GLib, Gtk
    from gi.repository import Gtk4LayerShell as LayerShell
except Exception:
    _log(traceback.format_exc())
    raise

import calendar
import datetime
import json
import os
import re
import shutil
import subprocess
import threading

APP_ID = "dev.nixos.control-center"
MONITOR_NAME = os.environ.get("CC_MONITOR")
LOCAL_MONITORS_CONF = os.path.expanduser("~/.config/hypr/local/monitors.lua")
NIGHTLIGHT_STATE = os.path.expanduser("~/.cache/control-center/nightlight")
PERF_STATE = os.path.expanduser("~/.cache/control-center/performance")
THEME_STATE = os.path.expanduser("~/.cache/control-center/theme")

TARGET_MONITOR_FILE = os.path.expanduser("~/.cache/control-center/target-monitor")


def get_target_monitor():
    try:
        with open(TARGET_MONITOR_FILE) as f:
            name = f.read().strip()
        return name or None
    except OSError:
        return None


def run(cmd, timeout=4):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
        return 1, "", str(exc)


def run_bg(cmd):
    try:
        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except FileNotFoundError:
        _log(f"missing binary for: {cmd}")


def has(binary):
    return shutil.which(binary) is not None


def ensure_state_dir():
    os.makedirs(os.path.dirname(NIGHTLIGHT_STATE), exist_ok=True)
    os.makedirs(os.path.dirname(PERF_STATE), exist_ok=True)
    os.makedirs(os.path.dirname(THEME_STATE), exist_ok=True)


def run_off_thread(work, on_done):
    """Run `work()` (a blocking call, e.g. bluetoothctl) on a background
    thread and deliver its return value to `on_done(result)` back on the
    GTK main thread via GLib.idle_add. This is what keeps slow bluetoothctl
    round-trips from freezing the whole panel while it's open."""

    def _worker():
        try:
            result = work()
        except Exception:
            _log(traceback.format_exc())
            result = None
        GLib.idle_add(on_done, result)

    threading.Thread(target=_worker, daemon=True).start()


class WifiBackend:
    available = has("nmcli")

    @staticmethod
    def radio_enabled():
        code, out, _ = run(["nmcli", "radio", "wifi"])
        return out.strip().lower() == "enabled"

    @staticmethod
    def set_radio(enabled):
        run(["nmcli", "radio", "wifi", "on" if enabled else "off"])

    @staticmethod
    def current_ssid():
        code, out, _ = run(["nmcli", "-t", "-f", "active,ssid", "dev", "wifi"])
        for line in out.splitlines():
            if line.startswith("yes:"):
                return line.split(":", 1)[1]
        return None

    @staticmethod
    def scan():
        run(["nmcli", "dev", "wifi", "rescan"], timeout=6)

    @staticmethod
    def list_networks():
        code, out, _ = run(
            [
                "nmcli",
                "-t",
                "-f",
                "active,ssid,signal,security",
                "dev",
                "wifi",
                "list",
            ]
        )
        seen = set()
        nets = []
        for line in out.splitlines():
            parts = line.split(":")
            if len(parts) < 4:
                continue
            active, ssid, signal, security = (
                parts[0],
                parts[1],
                parts[2],
                ":".join(parts[3:]),
            )
            if not ssid or ssid in seen:
                continue
            seen.add(ssid)
            try:
                signal_i = int(signal)
            except ValueError:
                signal_i = 0
            nets.append(
                {
                    "ssid": ssid,
                    "active": active == "yes",
                    "signal": signal_i,
                    "secure": bool(security.strip()),
                }
            )
        nets.sort(key=lambda n: (-n["active"], -n["signal"]))
        return nets

    @staticmethod
    def connect(ssid, password=None):
        cmd = ["nmcli", "dev", "wifi", "connect", ssid]
        if password:
            cmd += ["password", password]
        return run(cmd, timeout=15)

    @staticmethod
    def disconnect():
        code, out, _ = run(["nmcli", "-t", "-f", "device,type", "dev", "status"])
        for line in out.splitlines():
            dev, typ = (line.split(":") + [""])[:2]
            if typ == "wifi":
                run(["nmcli", "dev", "disconnect", dev])


class HotspotBackend:
    available = has("nmcli")
    CON_NAME = "Hotspot"

    @staticmethod
    def list_wifi_devices():
        """All network devices of type 'wifi', as (ifname, state) pairs."""
        code, out, _ = run(["nmcli", "-t", "-f", "device,type,state", "dev", "status"])
        devices = []
        for line in out.splitlines():
            parts = (line.split(":") + ["", "", ""])[:3]
            dev, typ, state = parts
            if typ == "wifi" and dev:
                devices.append((dev, state))
        return devices

    @classmethod
    def _exists(cls):
        code, out, _ = run(["nmcli", "-t", "-f", "name", "con", "show"])
        return cls.CON_NAME in out.splitlines()

    @classmethod
    def is_active(cls):
        code, out, _ = run(["nmcli", "-t", "-f", "name", "con", "show", "--active"])
        return cls.CON_NAME in out.splitlines()

    @classmethod
    def current_config(cls):
        """Returns (ssid, band, ifname) for the saved Hotspot profile, or
        (None, None, None) if it hasn't been configured yet."""
        if not cls._exists():
            return None, None, None
        code, out, _ = run(
            [
                "nmcli",
                "-t",
                "-f",
                "802-11-wireless.ssid,802-11-wireless.band,connection.interface-name",
                "con",
                "show",
                cls.CON_NAME,
            ]
        )
        ssid, band, ifname = None, None, None
        for line in out.splitlines():
            if line.startswith("802-11-wireless.ssid:"):
                ssid = line.split(":", 1)[1]
            elif line.startswith("802-11-wireless.band:"):
                band = line.split(":", 1)[1]
            elif line.startswith("connection.interface-name:"):
                ifname = line.split(":", 1)[1]
        return ssid, band, ifname

    @classmethod
    def configure(cls, ssid, password, ifname, band="bg"):
        """Create or update the saved Hotspot profile on the given wifi
        interface. Does not turn it on."""
        if not ifname:
            return 1, "", "no wifi interface selected"
        if cls._exists():
            run(["nmcli", "con", "down", cls.CON_NAME], timeout=10)
            run(["nmcli", "con", "delete", cls.CON_NAME])
        cmd = [
            "nmcli",
            "con",
            "add",
            "type",
            "wifi",
            "ifname",
            ifname,
            "con-name",
            cls.CON_NAME,
            "autoconnect",
            "no",
            "ssid",
            ssid,
        ]
        code, out, err = run(cmd, timeout=10)
        if code != 0:
            return code, out, err

        run(
            [
                "nmcli",
                "con",
                "modify",
                cls.CON_NAME,
                "802-11-wireless.mode",
                "ap",
                "802-11-wireless.band",
                band,
                "ipv4.method",
                "shared",
                "ipv6.method",
                "ignore",
                "connection.autoconnect-priority",
                "999",
            ]
        )
        if password:
            run(
                [
                    "nmcli",
                    "con",
                    "modify",
                    cls.CON_NAME,
                    "wifi-sec.key-mgmt",
                    "wpa-psk",
                    "wifi-sec.psk",
                    password,
                ]
            )
        else:
            run(["nmcli", "con", "modify", cls.CON_NAME, "wifi-sec.key-mgmt", ""])
        return 0, "", ""

    @classmethod
    def set_active(cls, enabled):
        if enabled:
            if not cls._exists():
                return 1, "", "hotspot not configured"
            return run(["nmcli", "con", "up", cls.CON_NAME], timeout=15)
        return run(["nmcli", "con", "down", cls.CON_NAME], timeout=10)

class BluetoothBackend:
    available = has("bluetoothctl")

    @staticmethod
    def powered():
        code, out, _ = run(["bluetoothctl", "show"])
        return "Powered: yes" in out

    @staticmethod
    def set_power(enabled):
        run(["bluetoothctl", "power", "on" if enabled else "off"])

    @staticmethod
    def list_devices():
        code, out, _ = run(["bluetoothctl", "devices"])
        _, paired_out, _ = run(["bluetoothctl", "devices", "Paired"])
        _, connected_out, _ = run(["bluetoothctl", "devices", "Connected"])

        def _macs(text):
            return {m.group(1) for m in re.finditer(r"Device ([0-9A-Fa-f:]+) ", text)}

        paired_macs = _macs(paired_out)
        connected_macs = _macs(connected_out)

        devices = []
        for line in out.splitlines():
            m = re.match(r"Device ([0-9A-Fa-f:]+) (.+)", line)
            if not m:
                continue
            mac, name = m.groups()
            devices.append(
                {
                    "mac": mac,
                    "name": name,
                    "connected": mac in connected_macs,
                    "paired": mac in paired_macs,
                }
            )
        devices.sort(key=lambda d: (-d["connected"], -d["paired"], d["name"]))
        return devices

    @staticmethod
    def connect(mac):
        return run(["bluetoothctl", "connect", mac], timeout=12)

    @staticmethod
    def disconnect(mac):
        return run(["bluetoothctl", "disconnect", mac], timeout=8)

    @staticmethod
    def start_scan_bg():
        run_bg(["bluetoothctl", "scan", "on"])

    @staticmethod
    def stop_scan():
        run(["bluetoothctl", "scan", "off"])


class VolumeBackend:
    available = has("pamixer")

    @staticmethod
    def get_volume():
        code, out, _ = run(["pamixer", "--get-volume"])
        try:
            return int(out.strip())
        except ValueError:
            return 0

    @staticmethod
    def is_muted():
        code, out, _ = run(["pamixer", "--get-mute"])
        return out.strip() == "true"

    @staticmethod
    def set_volume(value):
        value = max(0, min(100, value))
        run(["pamixer", "--set-volume", str(value)])

    @staticmethod
    def set_mute(muted):
        run(["pamixer", "--set-mute", "true" if muted else "false"])

    @staticmethod
    def list_sinks():
        code, out, _ = run(["pamixer", "--list-sinks"])
        sinks = []
        for line in out.splitlines():
            parts = line.split("\t")
            if len(parts) >= 2 and parts[0].strip().isdigit():
                sinks.append({"id": parts[0].strip(), "name": parts[-1].strip()})
        return sinks

    @staticmethod
    def set_default_sink(sink_id):
        run(["pactl", "set-default-sink", sink_id])


class MediaBackend:
    available = has("playerctl")
    _NAME_MAP = {
        "cider": "CIDER",
        "cider2": "CIDER",
        "spotify": "SPOTIFY",
        "firefox": "WEB",
        "chromium": "WEB",
        "google-chrome": "WEB",
        "brave": "WEB",
        "vlc": "VLC",
        "mpv": "MPV",
    }

    @classmethod
    def _active_player(cls):
        """Return the identity string of whichever player playerctl thinks
        is currently active/playing, or None if nothing is available."""
        code, out, _ = run(["playerctl", "-l"])
        if code != 0 or not out.strip():
            return None
        players = [p.strip() for p in out.splitlines() if p.strip()]

        playing, paused = [], []
        for p in players:
            pcode, pout, _ = run(["playerctl", "--player=" + p, "status"])
            if pcode != 0:
                continue
            if pout.strip() == "Playing":
                playing.append(p)
            else:
                paused.append(p)
        if playing:
            return playing[0]
        if paused:
            return paused[0]
        return None

    @classmethod
    def _display_name(cls, player_id):
        base = player_id.split(".")[0].lower()
        return cls._NAME_MAP.get(base, base.upper())

    @classmethod
    def status(cls):
        player = cls._active_player()
        if not player:
            return None
        code, out, _ = run(["playerctl", "--player=" + player, "status"])
        if code != 0:
            return None
        _, title, _ = run(["playerctl", "--player=" + player, "metadata", "title"])
        _, artist, _ = run(["playerctl", "--player=" + player, "metadata", "artist"])
        return {
            "playing": out.strip() == "Playing",
            "title": title.strip() or "Unknown title",
            "artist": artist.strip() or "Unknown artist",
            "source": cls._display_name(player),
        }

    @classmethod
    def play_pause(cls):
        player = cls._active_player()
        if player:
            run(["playerctl", "--player=" + player, "play-pause"])

    @classmethod
    def next(cls):
        player = cls._active_player()
        if player:
            run(["playerctl", "--player=" + player, "next"])

    @classmethod
    def previous(cls):
        player = cls._active_player()
        if player:
            run(["playerctl", "--player=" + player, "previous"])


class DisplayBackend:
    available = has("hyprctl")

    @staticmethod
    def list_monitors():
        code, out, _ = run(["hyprctl", "-j", "monitors"])
        if code != 0 or not out:
            return []
        try:
            data = json.loads(out)
        except json.JSONDecodeError:
            return []
        monitors = []
        for m in data:
            modes = set()
            for mode in m.get("availableModes", []):
                match = re.match(r"(\d+)x(\d+)@([\d.]+)Hz?", mode)
                if match:
                    w, h, r = match.groups()
                    modes.add((int(w), int(h), round(float(r), 2)))
            monitors.append(
                {
                    "name": m.get("name"),
                    "description": m.get("description", m.get("name")),
                    "width": m.get("width"),
                    "height": m.get("height"),
                    "refresh": round(m.get("refreshRate", 0), 2),
                    "x": m.get("x"),
                    "y": m.get("y"),
                    "scale": m.get("scale", 1.0),
                    "disabled": m.get("disabled", False),
                    "modes": sorted(modes, key=lambda t: (-t[0], -t[1], -t[2])),
                }
            )
        return monitors

    @staticmethod
    def apply_live(name, width, height, refresh, x, y, scale=1.0):
        run(
            [
                "hyprctl",
                "eval",
                f'hl.monitor({{ output = "{name}", '
                f'mode = "{width}x{height}@{refresh}", '
                f'position = "{x}x{y}", '
                f"scale = {scale} }})",
            ]
        )

    @staticmethod
    def read_persisted_lines():
        try:
            with open(LOCAL_MONITORS_CONF) as f:
                return [ln.rstrip("\n") for ln in f]
        except OSError:
            return []

    @classmethod
    def persist(cls, name, width, height, refresh, x, y, scale=1.0):
        """Write/replace an `hl.monitor({ output = "name", ... })` call in
        ~/.config/hypr/local/monitors.lua so the layout survives reboots.
        hyprland.lua already `require`s this file right after the shipped
        monitors.lua, so a call here simply overrides the default for
        that connector — the same override mechanism home.nix's
        hyprLocalOverrides activation script already sets up.

        Each monitor is kept on exactly one line so the whole entry can be
        matched and replaced by output name without parsing Lua.
        """
        os.makedirs(os.path.dirname(LOCAL_MONITORS_CONF), exist_ok=True)
        lines = cls.read_persisted_lines()
        new_line = (
            f'hl.monitor({{ output = "{name}", '
            f'mode = "{width}x{height}@{refresh}", '
            f'position = "{x}x{y}", '
            f"scale = {scale} }})"
        )
        pattern = re.compile(
            rf'^\s*hl\.monitor\(\{{\s*output\s*=\s*"{re.escape(name)}"'
        )
        replaced = False
        for i, ln in enumerate(lines):
            if pattern.match(ln):
                lines[i] = new_line
                replaced = True
                break
        if not replaced:
            lines.append(new_line)
        with open(LOCAL_MONITORS_CONF, "w") as f:
            f.write("\n".join(lines) + "\n")

    @staticmethod
    def set_disabled(name, disabled):
        spec = (
            f'{{ output = "{name}", disabled = true }}'
            if disabled
            else f'{{ output = "{name}", mode = "preferred", '
            f'position = "auto", scale = 1 }}'
        )
        run(["hyprctl", "eval", f"hl.monitor({spec})"])


class NightLightBackend:
    available = has("hyprsunset")

    @staticmethod
    def is_enabled():
        ensure_state_dir()
        return os.path.exists(NIGHTLIGHT_STATE)

    @staticmethod
    def set_enabled(enabled):
        ensure_state_dir()
        run(["pkill", "-x", "hyprsunset"])
        if enabled:
            run_bg(["hyprsunset", "-t", "4000"])
            open(NIGHTLIGHT_STATE, "w").close()
        elif os.path.exists(NIGHTLIGHT_STATE):
            os.remove(NIGHTLIGHT_STATE)


class PerformanceBackend:
    gaming_script = os.path.expanduser("~/NixOS/Scripts/gaming.sh")
    restore_script = os.path.expanduser("~/NixOS/Scripts/rice-restore.sh")
    available = os.path.exists(gaming_script)

    @staticmethod
    def is_gaming_mode():
        ensure_state_dir()
        return os.path.exists(PERF_STATE)

    @classmethod
    def set_gaming_mode(cls, enabled):
        ensure_state_dir()
        script = cls.gaming_script if enabled else cls.restore_script
        run_bg(["bash", script])
        if enabled:
            open(PERF_STATE, "w").close()
        elif os.path.exists(PERF_STATE):
            os.remove(PERF_STATE)


class ThemeBackend:
    """Rice/palette switcher for the quick-settings 'Theme' panel.

    This currently only tracks and persists which palette is selected so
    the picker UI has something real to point at and highlight. Actually
    re-ricing the desktop (waybar/hypr/kitty/etc. colors) is wired up
    separately in a follow-up step: if ~/NixOS/Scripts/apply-theme.sh
    exists, set_theme() will call it with the chosen theme id; until then
    it's a no-op beyond remembering the choice.
    """

    THEMES = [
        {
            "id": "noir",
            "name": "Noir",
            "desc": "Monochrome black & white (current default)",
            "swatch": ["#050505", "#1a1a1a", "#e8e8e8", "#ffffff"],
        },
        {
            "id": "nord",
            "name": "Nord",
            "desc": "Cool arctic blues",
            "swatch": ["#2e3440", "#3b4252", "#88c0d0", "#eceff4"],
        },
        {
            "id": "dracula",
            "name": "Dracula",
            "desc": "Purple-tinted dark",
            "swatch": ["#282a36", "#44475a", "#bd93f9", "#f8f8f2"],
        },
        {
            "id": "gruvbox",
            "name": "Gruvbox",
            "desc": "Warm retro contrast",
            "swatch": ["#282828", "#3c3836", "#fabd2f", "#ebdbb2"],
        },
        {
            "id": "catppuccin",
            "name": "Catppuccin Mocha",
            "desc": "Soft pastel dark",
            "swatch": ["#1e1e2e", "#313244", "#f5c2e7", "#cdd6f4"],
        },
    ]

    available = True
    apply_script = os.path.expanduser("~/NixOS/Scripts/apply-theme.sh")

    @classmethod
    def current(cls):
        ensure_state_dir()
        try:
            with open(THEME_STATE) as f:
                value = f.read().strip()
            if any(t["id"] == value for t in cls.THEMES):
                return value
        except OSError:
            pass
        return "noir"

    @classmethod
    def current_name(cls):
        current_id = cls.current()
        for t in cls.THEMES:
            if t["id"] == current_id:
                return t["name"]
        return "Noir"

    @classmethod
    def set_theme(cls, theme_id):
        ensure_state_dir()
        with open(THEME_STATE, "w") as f:
            f.write(theme_id)
        if os.path.exists(cls.apply_script):
            run_bg(["bash", cls.apply_script, theme_id])


class DndBackend:
    available = has("swaync-client")

    @staticmethod
    def is_enabled():
        code, out, _ = run(["swaync-client", "-D"])
        return out.strip() == "true"

    @staticmethod
    def set_enabled(enabled):
        run(["swaync-client", "-dn" if enabled else "-df"])


def make_row_button(icon, title, subtitle_getter, on_click):
    """A quick-settings row: icon, title, dynamic subtitle, chevron.
    Clicking anywhere on the row opens its detail panel."""
    btn = Gtk.Button()
    btn.add_css_class("qs-row")
    btn.connect("clicked", on_click)

    box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
    box.set_margin_top(2)
    box.set_margin_bottom(2)

    icon_lbl = Gtk.Label(label=icon)
    icon_lbl.add_css_class("qs-row-icon")
    box.append(icon_lbl)

    text_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
    text_box.set_hexpand(True)
    text_box.set_valign(Gtk.Align.CENTER)

    title_lbl = Gtk.Label(label=title)
    title_lbl.add_css_class("qs-row-title")
    title_lbl.set_halign(Gtk.Align.START)
    text_box.append(title_lbl)

    sub_lbl = Gtk.Label(label=subtitle_getter() if subtitle_getter else "")
    sub_lbl.add_css_class("qs-row-subtitle")
    sub_lbl.set_halign(Gtk.Align.START)
    sub_lbl.set_ellipsize(3)
    text_box.append(sub_lbl)

    box.append(text_box)

    chevron = Gtk.Label(label="\u203a")
    chevron.add_css_class("qs-row-chevron")
    box.append(chevron)

    btn.set_child(box)
    return btn, sub_lbl


def make_toggle_row(icon, title, subtitle, active, on_toggle):
    box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
    box.add_css_class("qs-row")

    icon_lbl = Gtk.Label(label=icon)
    icon_lbl.add_css_class("qs-row-icon")
    box.append(icon_lbl)

    text_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
    text_box.set_hexpand(True)
    text_box.set_valign(Gtk.Align.CENTER)
    title_lbl = Gtk.Label(label=title)
    title_lbl.add_css_class("qs-row-title")
    title_lbl.set_halign(Gtk.Align.START)
    text_box.append(title_lbl)
    if subtitle:
        sub_lbl = Gtk.Label(label=subtitle)
        sub_lbl.add_css_class("qs-row-subtitle")
        sub_lbl.set_halign(Gtk.Align.START)
        text_box.append(sub_lbl)
    box.append(text_box)

    switch = Gtk.Switch()
    switch.set_active(active)
    switch.set_valign(Gtk.Align.CENTER)
    handler_id = switch.connect(
        "state-set", lambda w, state: (on_toggle(state), False)[1]
    )
    switch._toggle_handler_id = handler_id
    box.append(switch)

    return box, switch


def set_switch_active_silently(switch, active):
    """Programmatically correct a switch's state (e.g. after a failed
    backend call) without re-triggering its own 'state-set' handler,
    which would otherwise cause the toggle to loop back and forth."""
    handler_id = getattr(switch, "_toggle_handler_id", None)
    if handler_id is not None:
        switch.handler_block(handler_id)
    switch.set_active(active)
    switch.set_state(active)
    if handler_id is not None:
        switch.handler_unblock(handler_id)


def section_header(back_cb, title):
    header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
    header.set_margin_bottom(10)

    back = Gtk.Button(label="\u2039")
    back.add_css_class("detail-back")
    back.connect("clicked", back_cb)
    header.append(back)

    lbl = Gtk.Label(label=title)
    lbl.add_css_class("detail-title")
    lbl.set_halign(Gtk.Align.START)
    lbl.set_hexpand(True)
    header.append(lbl)

    return header


class WifiPanel(Gtk.Box):
    def __init__(self, go_back):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.append(section_header(lambda *_: go_back(), "Wi-Fi"))

        if not WifiBackend.available:
            self.append(self._unavailable("NetworkManager (nmcli) not found"))
            return

        enabled = WifiBackend.radio_enabled()
        toggle_row, self.switch = make_toggle_row(
            "\uf1eb", "Wi-Fi", None, enabled, self._on_toggle
        )
        self.append(toggle_row)

        self.list_box = Gtk.ListBox()
        self.list_box.add_css_class("detail-list")
        self.list_box.set_selection_mode(Gtk.SelectionMode.NONE)

        scroller = Gtk.ScrolledWindow()
        scroller.set_min_content_height(220)
        scroller.set_max_content_height(260)
        scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroller.set_child(self.list_box)
        scroller.set_margin_top(8)
        self.append(scroller)

        refresh_btn = Gtk.Button(label="Scan for networks")
        refresh_btn.add_css_class("detail-action")
        refresh_btn.set_margin_top(8)
        refresh_btn.connect("clicked", self._on_scan)
        self.append(refresh_btn)

        self._populate()

    def _unavailable(self, msg):
        lbl = Gtk.Label(label=msg)
        lbl.add_css_class("qs-row-subtitle")
        return lbl

    def _on_toggle(self, state):
        WifiBackend.set_radio(state)
        GLib.timeout_add(400, lambda: (self._populate(), False)[1])

    def _on_scan(self, _btn):
        WifiBackend.scan()
        GLib.timeout_add(1200, lambda: (self._populate(), False)[1])

    def _populate(self):
        child = self.list_box.get_first_child()
        while child:
            nxt = child.get_next_sibling()
            self.list_box.remove(child)
            child = nxt

        for net in WifiBackend.list_networks():
            row = Gtk.ListBoxRow()
            row.add_css_class("detail-list-row")
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)

            bars = "\uf1eb" if net["signal"] >= 60 else "\uf6ab"
            icon = Gtk.Label(label=bars)
            icon.add_css_class("detail-list-icon")
            hbox.append(icon)

            name = Gtk.Label(label=net["ssid"])
            name.set_halign(Gtk.Align.START)
            name.set_hexpand(True)
            if net["active"]:
                name.add_css_class("detail-list-active")
            hbox.append(name)

            if net["secure"]:
                lock = Gtk.Label(label="\uf023")
                lock.add_css_class("detail-list-icon")
                hbox.append(lock)

            if net["active"]:
                tag = Gtk.Label(label="Connected")
                tag.add_css_class("detail-list-tag")
                hbox.append(tag)

            row.set_child(hbox)
            row.connect(
                "activate",
                lambda *_a, n=net: self._on_network_clicked(n),
            )
            gesture = Gtk.GestureClick()
            gesture.connect("released", lambda *_a, n=net: self._on_network_clicked(n))
            row.add_controller(gesture)
            self.list_box.append(row)

    def _on_network_clicked(self, net):
        if net["active"]:
            WifiBackend.disconnect()
            GLib.timeout_add(500, lambda: (self._populate(), False)[1])
            return
        if not net["secure"]:
            WifiBackend.connect(net["ssid"])
            GLib.timeout_add(1500, lambda: (self._populate(), False)[1])
            return
        self._prompt_password(net["ssid"])

    def _prompt_password(self, ssid):
        dialog = Gtk.Window()
        dialog.add_css_class("cc-popup-window")
        dialog.set_decorated(False)
        dialog.set_modal(True)
        dialog.set_transient_for(self.get_root())

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.add_css_class("password-dialog")

        lbl = Gtk.Label(label=f"Password for \u201c{ssid}\u201d")
        lbl.add_css_class("detail-title")
        box.append(lbl)

        entry = Gtk.PasswordEntry()
        entry.set_show_peek_icon(True)
        entry.add_css_class("password-entry")
        box.append(entry)

        btn_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        btn_row.set_halign(Gtk.Align.END)
        cancel = Gtk.Button(label="Cancel")
        cancel.add_css_class("detail-action")
        cancel.connect("clicked", lambda *_: dialog.destroy())
        connect = Gtk.Button(label="Connect")
        connect.add_css_class("detail-action-primary")

        def do_connect(*_a):
            WifiBackend.connect(ssid, entry.get_text())
            dialog.destroy()
            GLib.timeout_add(1500, lambda: (self._populate(), False)[1])

        connect.connect("clicked", do_connect)
        entry.connect("activate", do_connect)

        btn_row.append(cancel)
        btn_row.append(connect)
        box.append(btn_row)

        dialog.set_child(box)
        dialog.present()
        entry.grab_focus()


class HotspotPanel(Gtk.Box):
    def __init__(self, go_back):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.append(section_header(lambda *_: go_back(), "Mobile Hotspot"))

        if not HotspotBackend.available:
            self.append(self._unavailable("NetworkManager (nmcli) not found"))
            return

        self._busy = False

        active = HotspotBackend.is_active()
        toggle_row, self.switch = make_toggle_row(
            "\uf519", "Hotspot", None, active, self._on_toggle
        )
        self.append(toggle_row)

        ssid, band, saved_ifname = HotspotBackend.current_config()

        form = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        form.set_margin_top(10)

        self.wifi_devices = HotspotBackend.list_wifi_devices()

        if not self.wifi_devices:
            self.append(self._unavailable("No Wi-Fi device found"))
            self.iface_dropdown = None
        else:
            iface_lbl = Gtk.Label(label="Wi-Fi device")
            iface_lbl.add_css_class("qs-row-subtitle")
            iface_lbl.set_halign(Gtk.Align.START)
            form.append(iface_lbl)

            iface_names = [d for d, _state in self.wifi_devices]
            self.iface_dropdown = Gtk.DropDown.new_from_strings(iface_names)
            self.iface_dropdown.add_css_class("monitor-dropdown")
            try:
                default_idx = (
                    iface_names.index(saved_ifname)
                    if saved_ifname in iface_names
                    else 0
                )
            except ValueError:
                default_idx = 0
            self.iface_dropdown.set_selected(default_idx)
            form.append(self.iface_dropdown)

        ssid_lbl = Gtk.Label(label="Network name")
        ssid_lbl.add_css_class("qs-row-subtitle")
        ssid_lbl.set_halign(Gtk.Align.START)
        form.append(ssid_lbl)

        self.ssid_entry = Gtk.Entry()
        self.ssid_entry.add_css_class("password-entry")
        self.ssid_entry.set_text(ssid or f"{os.environ.get('USER', 'nixos')}-hotspot")
        form.append(self.ssid_entry)

        pass_lbl = Gtk.Label(label="Password (min. 8 characters)")
        pass_lbl.add_css_class("qs-row-subtitle")
        pass_lbl.set_halign(Gtk.Align.START)
        pass_lbl.set_margin_top(6)
        form.append(pass_lbl)

        self.pass_entry = Gtk.PasswordEntry()
        self.pass_entry.set_show_peek_icon(True)
        self.pass_entry.add_css_class("password-entry")
        form.append(self.pass_entry)

        band_lbl = Gtk.Label(label="Band")
        band_lbl.add_css_class("qs-row-subtitle")
        band_lbl.set_halign(Gtk.Align.START)
        band_lbl.set_margin_top(6)
        form.append(band_lbl)

        self.band_dropdown = Gtk.DropDown.new_from_strings(["2.4 GHz", "5 GHz"])
        self.band_dropdown.add_css_class("monitor-dropdown")
        self.band_dropdown.set_selected(1 if band == "a" else 0)
        form.append(self.band_dropdown)

        save_btn = Gtk.Button(label="Save")
        save_btn.add_css_class("detail-action-primary")
        save_btn.set_margin_top(10)
        save_btn.connect("clicked", self._on_save)
        form.append(save_btn)

        self.status_lbl = Gtk.Label(label="")
        self.status_lbl.add_css_class("qs-row-subtitle")
        self.status_lbl.set_halign(Gtk.Align.START)
        self.status_lbl.set_margin_top(4)
        form.append(self.status_lbl)

        self.append(form)

        if not ssid:
            self.status_lbl.set_label("Set a name and password, then Save, to enable the toggle above.")

    def _unavailable(self, msg):
        lbl = Gtk.Label(label=msg)
        lbl.add_css_class("qs-row-subtitle")
        return lbl

    def _on_save(self, _btn):
        ssid = self.ssid_entry.get_text().strip()
        password = self.pass_entry.get_text()
        band = "a" if self.band_dropdown.get_selected() == 1 else "bg"

        if self.iface_dropdown is None:
            self.status_lbl.set_label("No Wi-Fi device found.")
            return
        idx = self.iface_dropdown.get_selected()
        if idx < 0 or idx >= len(self.wifi_devices):
            self.status_lbl.set_label("Select a Wi-Fi device.")
            return
        ifname = self.wifi_devices[idx][0]

        if not ssid:
            self.status_lbl.set_label("Network name can't be empty.")
            return
        if password and len(password) < 8:
            self.status_lbl.set_label("Password must be at least 8 characters.")
            return

        was_active = HotspotBackend.is_active()
        self.status_lbl.set_label("Saving\u2026")

        def work():
            return HotspotBackend.configure(ssid, password, ifname, band)

        def done(result):
            code, _out, err = result if result else (1, "", "unknown error")
            if code != 0:
                self.status_lbl.set_label(f"Failed to save: {err or 'unknown error'}")
                return
            if not was_active:
                self.status_lbl.set_label("Saved.")
                return
            self.status_lbl.set_label("Saved. Restarting hotspot\u2026")
            self._busy = True

            def reactivate():
                return HotspotBackend.set_active(True)

            def reactivate_done(react_result):
                self._busy = False
                r_code, _r_out, r_err = (
                    react_result if react_result else (1, "", "unknown error")
                )
                if r_code != 0:
                    self.status_lbl.set_label(
                        f"Saved, but failed to restart: {r_err or 'unknown error'}"
                    )
                    set_switch_active_silently(self.switch, False)
                else:
                    self.status_lbl.set_label("Saved.")
                    set_switch_active_silently(self.switch, True)

            run_off_thread(reactivate, reactivate_done)

        run_off_thread(work, done)

    def _on_toggle(self, state):
        if self._busy:
            return True  # ignore re-entrant toggles while one is in flight, keep switch as-is

        ssid, _band, _ifname = HotspotBackend.current_config()
        if state and not ssid:
            self.status_lbl.set_label("Set a name and password, then Save, before enabling.")
            GLib.idle_add(lambda: (set_switch_active_silently(self.switch, False), False)[1])
            return False

        self._busy = True
        self.status_lbl.set_label("Turning on\u2026" if state else "Turning off\u2026")

        def work():
            return HotspotBackend.set_active(state)

        def done(result):
            self._busy = False
            code, _out, err = result if result else (1, "", "unknown error")
            if code != 0:
                self.status_lbl.set_label(f"Failed: {err or 'unknown error'}")
                set_switch_active_silently(self.switch, not state)
            else:
                self.status_lbl.set_label("")

        run_off_thread(work, done)
        return False


class BluetoothPanel(Gtk.Box):
    def __init__(self, go_back):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.append(section_header(lambda *_: go_back(), "Bluetooth"))

        if not BluetoothBackend.available:
            lbl = Gtk.Label(label="bluetoothctl not found")
            lbl.add_css_class("qs-row-subtitle")
            self.append(lbl)
            return

        toggle_row, self.switch = make_toggle_row(
            "\uf294", "Bluetooth", None, BluetoothBackend.powered(), self._on_toggle
        )
        self.append(toggle_row)

        self.list_box = Gtk.ListBox()
        self.list_box.add_css_class("detail-list")
        self.list_box.set_selection_mode(Gtk.SelectionMode.NONE)

        scroller = Gtk.ScrolledWindow()
        scroller.set_min_content_height(200)
        scroller.set_max_content_height(240)
        scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroller.set_child(self.list_box)
        scroller.set_margin_top(8)
        self.append(scroller)

        scan_btn = Gtk.Button(label="Scan for devices")
        scan_btn.add_css_class("detail-action")
        scan_btn.set_margin_top(8)
        scan_btn.connect("clicked", self._on_scan)
        self.append(scan_btn)

        self._populate()

    def _on_toggle(self, state):
        run_off_thread(
            lambda: BluetoothBackend.set_power(state),
            lambda _res: GLib.timeout_add(400, lambda: (self._populate(), False)[1]),
        )

    def _on_scan(self, _btn):
        BluetoothBackend.start_scan_bg()
        GLib.timeout_add(4000, self._stop_and_refresh)

    def _stop_and_refresh(self):
        run_off_thread(BluetoothBackend.stop_scan, lambda _res: self._populate())
        return False

    def _populate(self):
        run_off_thread(BluetoothBackend.list_devices, self._render_devices)

    def _render_devices(self, devices):
        if devices is None:
            return
        child = self.list_box.get_first_child()
        while child:
            nxt = child.get_next_sibling()
            self.list_box.remove(child)
            child = nxt

        for dev in devices:
            row = Gtk.ListBoxRow()
            row.add_css_class("detail-list-row")
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)

            icon = Gtk.Label(label="\uf294")
            icon.add_css_class("detail-list-icon")
            hbox.append(icon)

            name = Gtk.Label(label=dev["name"])
            name.set_halign(Gtk.Align.START)
            name.set_hexpand(True)
            name.set_ellipsize(3)
            if dev["connected"]:
                name.add_css_class("detail-list-active")
            hbox.append(name)

            if dev["connected"]:
                tag = Gtk.Label(label="Connected")
                tag.add_css_class("detail-list-tag")
                hbox.append(tag)

            row.set_child(hbox)
            gesture = Gtk.GestureClick()
            gesture.connect("released", lambda *_a, d=dev: self._on_device_clicked(d))
            row.add_controller(gesture)
            self.list_box.append(row)

    def _on_device_clicked(self, dev):
        action = (
            BluetoothBackend.disconnect
            if dev["connected"]
            else BluetoothBackend.connect
        )
        run_off_thread(lambda: action(dev["mac"]), lambda _res: self._populate())


class VolumePanel(Gtk.Box):
    def __init__(self, go_back):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.append(section_header(lambda *_: go_back(), "Volume"))

        if not VolumeBackend.available:
            lbl = Gtk.Label(label="pamixer not found")
            lbl.add_css_class("qs-row-subtitle")
            self.append(lbl)
            return

        muted = VolumeBackend.is_muted()
        vol = VolumeBackend.get_volume()

        slider_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        slider_row.add_css_class("qs-row")

        self.mute_btn = Gtk.Button(label="\uf026" if muted else "\uf028")
        self.mute_btn.add_css_class("volume-mute-btn")
        self.mute_btn.connect("clicked", self._on_mute)
        slider_row.append(self.mute_btn)

        self.adj = Gtk.Adjustment(
            value=vol, lower=0, upper=100, step_increment=1, page_increment=5
        )
        self.scale = Gtk.Scale(
            orientation=Gtk.Orientation.HORIZONTAL, adjustment=self.adj
        )
        self.scale.set_hexpand(True)
        self.scale.set_draw_value(False)
        self.scale.add_css_class("volume-scale")
        self.scale.connect("value-changed", self._on_scale)
        slider_row.append(self.scale)

        self.pct_lbl = Gtk.Label(label=f"{vol}%")
        self.pct_lbl.add_css_class("volume-pct")
        slider_row.append(self.pct_lbl)

        self.append(slider_row)

        sinks = VolumeBackend.list_sinks()
        if len(sinks) > 1:
            out_lbl = Gtk.Label(label="Output device")
            out_lbl.add_css_class("detail-subheading")
            out_lbl.set_halign(Gtk.Align.START)
            out_lbl.set_margin_top(10)
            self.append(out_lbl)

            sink_list = Gtk.ListBox()
            sink_list.add_css_class("detail-list")
            sink_list.set_selection_mode(Gtk.SelectionMode.NONE)
            for sink in sinks:
                row = Gtk.ListBoxRow()
                row.add_css_class("detail-list-row")
                lbl = Gtk.Label(label=sink["name"])
                lbl.set_halign(Gtk.Align.START)
                lbl.set_ellipsize(3)
                row.set_child(lbl)
                gesture = Gtk.GestureClick()
                gesture.connect(
                    "released",
                    lambda *_a, s=sink: VolumeBackend.set_default_sink(s["id"]),
                )
                row.add_controller(gesture)
                sink_list.append(row)
            self.append(sink_list)

    def _on_mute(self, _btn):
        muted = not (self.mute_btn.get_label() == "\uf026")
        VolumeBackend.set_mute(muted)
        self.mute_btn.set_label("\uf026" if muted else "\uf028")

    def _on_scale(self, scale):
        value = int(scale.get_value())
        VolumeBackend.set_volume(value)
        self.pct_lbl.set_label(f"{value}%")


class DisplaysPanel(Gtk.Box):
    def __init__(self, go_back):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.append(section_header(lambda *_: go_back(), "Displays"))

        if not DisplayBackend.available:
            lbl = Gtk.Label(label="hyprctl not found")
            lbl.add_css_class("qs-row-subtitle")
            self.append(lbl)
            return

        scroller = Gtk.ScrolledWindow()
        scroller.set_min_content_height(260)
        scroller.set_max_content_height(320)
        scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        inner = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        scroller.set_child(inner)
        self.append(scroller)

        for mon in DisplayBackend.list_monitors():
            inner.append(self._build_monitor_card(mon))

    def _build_monitor_card(self, mon):
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        card.add_css_class("monitor-card")

        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        name_lbl = Gtk.Label(label=mon["name"])
        name_lbl.add_css_class("monitor-card-name")
        name_lbl.set_halign(Gtk.Align.START)
        name_lbl.set_hexpand(True)
        header.append(name_lbl)

        enabled_switch = Gtk.Switch()
        enabled_switch.set_active(not mon["disabled"])
        enabled_switch.set_valign(Gtk.Align.CENTER)
        enabled_switch.connect(
            "state-set",
            lambda w, state, n=mon["name"]: (
                DisplayBackend.set_disabled(n, not state),
                False,
            )[1],
        )
        header.append(enabled_switch)
        card.append(header)

        desc_lbl = Gtk.Label(label=mon["description"])
        desc_lbl.add_css_class("qs-row-subtitle")
        desc_lbl.set_halign(Gtk.Align.START)
        desc_lbl.set_ellipsize(3)
        card.append(desc_lbl)

        res_options = sorted(
            {(w, h) for (w, h, r) in mon["modes"]}, key=lambda t: -t[0] * t[1]
        )
        res_strings = [f"{w}\u00d7{h}" for (w, h) in res_options]
        current_res = f"{mon['width']}\u00d7{mon['height']}"
        if current_res not in res_strings and res_strings:
            res_strings.insert(0, current_res)

        res_dropdown = Gtk.DropDown.new_from_strings(res_strings or [current_res])
        res_dropdown.add_css_class("monitor-dropdown")
        try:
            res_dropdown.set_selected(res_strings.index(current_res))
        except ValueError:
            pass

        refresh_dropdown = Gtk.DropDown.new_from_strings(["--"])
        refresh_dropdown.add_css_class("monitor-dropdown")

        def refresh_options_for(width, height):
            opts = sorted(
                {r for (w, h, r) in mon["modes"] if w == width and h == height},
                reverse=True,
            )
            return opts or [mon["refresh"]]

        def rebuild_refresh_dropdown(width, height):
            opts = refresh_options_for(width, height)
            model = Gtk.StringList.new([f"{r:g} Hz" for r in opts])
            refresh_dropdown.set_model(model)
            refresh_dropdown.set_selected(0)
            return opts

        cur_w, cur_h = mon["width"], mon["height"]
        current_refresh_opts = rebuild_refresh_dropdown(cur_w, cur_h)
        try:
            idx = current_refresh_opts.index(mon["refresh"])
            refresh_dropdown.set_selected(idx)
        except ValueError:
            pass

        def on_res_changed(dd, _pspec):
            sel = dd.get_selected()
            if sel < 0 or sel >= len(res_options):
                return
            w, h = res_options[sel]
            rebuild_refresh_dropdown(w, h)

        res_dropdown.connect("notify::selected", on_res_changed)

        picker_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        picker_row.append(res_dropdown)
        picker_row.append(refresh_dropdown)
        card.append(picker_row)

        pos_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        x_entry = Gtk.Entry()
        x_entry.set_text(str(mon["x"]))
        x_entry.add_css_class("monitor-pos-entry")
        x_entry.set_placeholder_text("X")
        y_entry = Gtk.Entry()
        y_entry.set_text(str(mon["y"]))
        y_entry.add_css_class("monitor-pos-entry")
        y_entry.set_placeholder_text("Y")
        pos_row.append(x_entry)
        pos_row.append(y_entry)
        card.append(pos_row)

        btn_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        btn_row.set_halign(Gtk.Align.END)

        def gather():
            sel = res_dropdown.get_selected()
            w, h = (
                res_options[sel]
                if 0 <= sel < len(res_options)
                else (mon["width"], mon["height"])
            )
            opts = refresh_options_for(w, h)
            rsel = refresh_dropdown.get_selected()
            refresh = opts[rsel] if 0 <= rsel < len(opts) else mon["refresh"]
            try:
                x = int(x_entry.get_text())
                y = int(y_entry.get_text())
            except ValueError:
                x, y = mon["x"], mon["y"]
            return w, h, refresh, x, y

        def on_apply(*_a):
            w, h, refresh, x, y = gather()
            DisplayBackend.apply_live(mon["name"], w, h, refresh, x, y, mon["scale"])

        def on_save(*_a):
            w, h, refresh, x, y = gather()
            DisplayBackend.apply_live(mon["name"], w, h, refresh, x, y, mon["scale"])
            DisplayBackend.persist(mon["name"], w, h, refresh, x, y, mon["scale"])
            save_btn.set_label("Saved")
            GLib.timeout_add(
                1400, lambda: (save_btn.set_label("Save layout"), False)[1]
            )

        apply_btn = Gtk.Button(label="Apply")
        apply_btn.add_css_class("detail-action")
        apply_btn.connect("clicked", on_apply)

        save_btn = Gtk.Button(label="Save layout")
        save_btn.add_css_class("detail-action-primary")
        save_btn.connect("clicked", on_save)

        btn_row.append(apply_btn)
        btn_row.append(save_btn)
        card.append(btn_row)

        return card


class ThemePanel(Gtk.Box):
    def __init__(self, go_back):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.append(section_header(lambda *_: go_back(), "Theme"))

        hint = Gtk.Label(label="Pick a rice palette for the whole desktop")
        hint.add_css_class("qs-row-subtitle")
        hint.set_halign(Gtk.Align.START)
        hint.set_margin_bottom(8)
        self.append(hint)

        self.list_box = Gtk.ListBox()
        self.list_box.add_css_class("detail-list")
        self.list_box.set_selection_mode(Gtk.SelectionMode.NONE)

        scroller = Gtk.ScrolledWindow()
        scroller.set_min_content_height(220)
        scroller.set_max_content_height(300)
        scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroller.set_child(self.list_box)
        self.append(scroller)

        self._populate()

    def _populate(self):
        child = self.list_box.get_first_child()
        while child:
            nxt = child.get_next_sibling()
            self.list_box.remove(child)
            child = nxt

        current = ThemeBackend.current()
        for theme in ThemeBackend.THEMES:
            row = Gtk.ListBoxRow()
            row.add_css_class("detail-list-row")
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)

            swatch = Gtk.Box()
            swatch.add_css_class("theme-swatch")
            swatch.add_css_class(f"theme-swatch-{theme['id']}")
            hbox.append(swatch)

            text_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
            text_box.set_hexpand(True)
            text_box.set_valign(Gtk.Align.CENTER)

            name_lbl = Gtk.Label(label=theme["name"])
            name_lbl.set_halign(Gtk.Align.START)
            if theme["id"] == current:
                name_lbl.add_css_class("detail-list-active")
            text_box.append(name_lbl)

            desc_lbl = Gtk.Label(label=theme["desc"])
            desc_lbl.add_css_class("qs-row-subtitle")
            desc_lbl.set_halign(Gtk.Align.START)
            text_box.append(desc_lbl)

            hbox.append(text_box)

            if theme["id"] == current:
                check = Gtk.Label(label="\uf00c")
                check.add_css_class("detail-list-icon")
                hbox.append(check)

            row.set_child(hbox)
            row.connect("activate", lambda *_a, t=theme: self._on_theme_clicked(t))
            gesture = Gtk.GestureClick()
            gesture.connect(
                "released", lambda *_a, t=theme: self._on_theme_clicked(t)
            )
            row.add_controller(gesture)
            self.list_box.append(row)

    def _on_theme_clicked(self, theme):
        if theme["id"] == ThemeBackend.current():
            return
        ThemeBackend.set_theme(theme["id"])
        self._populate()


class MiniCalendar(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.add_css_class("calendar-card")

        today = datetime.date.today()
        self.year = today.year
        self.month = today.month
        self.today = today

        nav = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        prev_btn = Gtk.Button(label="\u2039")
        prev_btn.add_css_class("calendar-nav")
        prev_btn.connect("clicked", lambda *_: self._shift(-1))
        self.month_lbl = Gtk.Label()
        self.month_lbl.add_css_class("calendar-month-label")
        self.month_lbl.set_hexpand(True)
        next_btn = Gtk.Button(label="\u203a")
        next_btn.add_css_class("calendar-nav")
        next_btn.connect("clicked", lambda *_: self._shift(1))
        nav.append(prev_btn)
        nav.append(self.month_lbl)
        nav.append(next_btn)
        self.append(nav)

        self.grid = Gtk.Grid()
        self.grid.set_row_spacing(4)
        self.grid.set_column_spacing(4)
        self.grid.set_column_homogeneous(True)
        self.append(self.grid)

        self._render()

    def _shift(self, delta):
        self.month += delta
        if self.month > 12:
            self.month = 1
            self.year += 1
        elif self.month < 1:
            self.month = 12
            self.year -= 1
        self._render()

    def _render(self):
        child = self.grid.get_first_child()
        while child:
            nxt = child.get_next_sibling()
            self.grid.remove(child)
            child = nxt

        self.month_lbl.set_label(
            datetime.date(self.year, self.month, 1).strftime("%B %Y")
        )

        for i, wd in enumerate(["M", "T", "W", "T", "F", "S", "S"]):
            lbl = Gtk.Label(label=wd)
            lbl.add_css_class("calendar-weekday")
            self.grid.attach(lbl, i, 0, 1, 1)

        cal = calendar.Calendar(firstweekday=0)
        row = 1
        for week in cal.monthdayscalendar(self.year, self.month):
            for col, day in enumerate(week):
                if day == 0:
                    lbl = Gtk.Label(label="")
                else:
                    lbl = Gtk.Label(label=str(day))
                    lbl.add_css_class("calendar-day")
                    if (
                        day == self.today.day
                        and self.month == self.today.month
                        and self.year == self.today.year
                    ):
                        lbl.add_css_class("calendar-day-today")
                self.grid.attach(lbl, col, row, 1, 1)
            row += 1


class NowPlaying(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add_css_class("nowplaying-card")

        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        icon = Gtk.Label(label="\uf001")
        icon.add_css_class("nowplaying-icon")
        header.append(icon)
        self.tag_lbl = Gtk.Label(label="")
        self.tag_lbl.add_css_class("nowplaying-tag")
        header.append(self.tag_lbl)
        self.append(header)

        self.title_lbl = Gtk.Label(label="Nothing playing")
        self.title_lbl.add_css_class("nowplaying-title")
        self.title_lbl.set_halign(Gtk.Align.START)
        self.title_lbl.set_ellipsize(3)
        self.append(self.title_lbl)

        self.artist_lbl = Gtk.Label(label="")
        self.artist_lbl.add_css_class("nowplaying-artist")
        self.artist_lbl.set_halign(Gtk.Align.START)
        self.artist_lbl.set_ellipsize(3)
        self.append(self.artist_lbl)

        controls = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        controls.set_halign(Gtk.Align.CENTER)
        controls.set_margin_top(4)

        prev_btn = Gtk.Button(label="\uf048")
        prev_btn.add_css_class("nowplaying-ctrl")
        prev_btn.connect(
            "clicked", lambda *_: (MediaBackend.previous(), self.refresh())
        )

        self.play_btn = Gtk.Button(label="\uf04b")
        self.play_btn.add_css_class("nowplaying-ctrl-main")
        self.play_btn.connect(
            "clicked", lambda *_: (MediaBackend.play_pause(), self.refresh())
        )

        next_btn = Gtk.Button(label="\uf051")
        next_btn.add_css_class("nowplaying-ctrl")
        next_btn.connect("clicked", lambda *_: (MediaBackend.next(), self.refresh()))

        controls.append(prev_btn)
        controls.append(self.play_btn)
        controls.append(next_btn)
        self.append(controls)

        self.refresh()
        GLib.timeout_add_seconds(3, self._tick)

    def _tick(self):
        self.refresh()
        return True

    def refresh(self):
        if not MediaBackend.available:
            self.tag_lbl.set_label("MEDIA")
            self.title_lbl.set_label("playerctl not found")
            self.artist_lbl.set_label("")
            return
        status = MediaBackend.status()
        if not status:
            self.tag_lbl.set_label("MEDIA")
            self.title_lbl.set_label("Nothing playing")
            self.artist_lbl.set_label("")
            self.play_btn.set_label("\uf04b")
            return
        self.tag_lbl.set_label(status["source"])
        self.title_lbl.set_label(status["title"])
        self.artist_lbl.set_label(status["artist"])
        self.play_btn.set_label("\uf04c" if status["playing"] else "\uf04b")


class QuickSettings(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.add_css_class("quicksettings-card")

        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        self.stack.set_transition_duration(180)
        self.append(self.stack)

        self.list_page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self._build_list_page()
        self.stack.add_named(self.list_page, "list")
        self.stack.set_visible_child_name("list")

    def _go_list(self):
        self.stack.set_visible_child_name("list")

    def _open(self, name, builder):
        existing = self.stack.get_child_by_name(name)
        if existing:
            self.stack.remove(existing)
        page = builder(self._go_list)
        self.stack.add_named(page, name)
        self.stack.set_visible_child_name(name)

    def _build_list_page(self):
        wifi_row, self.wifi_sub = make_row_button(
            "\uf1eb",
            "Wi-Fi",
            self._wifi_subtitle,
            lambda *_: self._open("wifi", WifiPanel),
        )
        self.list_page.append(wifi_row)

        hotspot_row, self.hotspot_sub = make_row_button(
            "\uf519",
            "Mobile Hotspot",
            self._hotspot_subtitle,
            lambda *_: self._open("hotspot", HotspotPanel),
        )
        self.list_page.append(hotspot_row)

        bt_row, self.bt_sub = make_row_button(
            "\uf294",
            "Bluetooth",
            self._bt_subtitle,
            lambda *_: self._open("bluetooth", BluetoothPanel),
        )
        self.list_page.append(bt_row)
        if BluetoothBackend.available and BluetoothBackend.powered():
            self._bt_subtitle_async(self.bt_sub)

        vol_row, self.vol_sub = make_row_button(
            "\uf028",
            "Volume",
            self._vol_subtitle,
            lambda *_: self._open("volume", VolumePanel),
        )
        self.list_page.append(vol_row)

        disp_row, self.disp_sub = make_row_button(
            "\uf108",
            "Displays",
            self._disp_subtitle,
            lambda *_: self._open("displays", DisplaysPanel),
        )
        self.list_page.append(disp_row)

        theme_row, self.theme_sub = make_row_button(
            "\uf1fc",
            "Theme",
            self._theme_subtitle,
            lambda *_: self._open("theme", ThemePanel),
        )
        self.list_page.append(theme_row)

        sep = Gtk.Separator()
        sep.add_css_class("qs-separator")
        sep.set_margin_top(6)
        sep.set_margin_bottom(6)
        self.list_page.append(sep)

        if NightLightBackend.available:
            nl_row, self.nl_switch = make_toggle_row(
                "\uf185",
                "Night Light",
                "Warmer colors after dark",
                NightLightBackend.is_enabled(),
                lambda state: NightLightBackend.set_enabled(state),
            )
            self.list_page.append(nl_row)

        if DndBackend.available:
            dnd_row, self.dnd_switch = make_toggle_row(
                "\uf1f6",
                "Do Not Disturb",
                "Silence notifications",
                DndBackend.is_enabled(),
                lambda state: DndBackend.set_enabled(state),
            )
            self.list_page.append(dnd_row)

        if PerformanceBackend.available:
            perf_row, self.perf_switch = make_toggle_row(
                "\uf135",
                "Performance Mode",
                "Low-latency, gaming profile",
                PerformanceBackend.is_gaming_mode(),
                lambda state: PerformanceBackend.set_gaming_mode(state),
            )
            self.list_page.append(perf_row)

    def _wifi_subtitle(self):
        if not WifiBackend.available:
            return "Unavailable"
        ssid = WifiBackend.current_ssid()
        return ssid if ssid else ("On" if WifiBackend.radio_enabled() else "Off")

    def _hotspot_subtitle(self):
        if not HotspotBackend.available:
            return "Unavailable"
        return "On" if HotspotBackend.is_active() else "Off"

    def _bt_subtitle(self):
        if not BluetoothBackend.available:
            return "Unavailable"
        if not BluetoothBackend.powered():
            return "Off"
        return "On"

    def _bt_subtitle_async(self, label):
        run_off_thread(
            lambda: [d for d in BluetoothBackend.list_devices() if d["connected"]],
            lambda devices: (
                label.set_label(devices[0]["name"] if devices else "On")
                if devices is not None
                else None
            ),
        )

    def _vol_subtitle(self):
        if not VolumeBackend.available:
            return "Unavailable"
        if VolumeBackend.is_muted():
            return "Muted"
        return f"{VolumeBackend.get_volume()}%"

    def _disp_subtitle(self):
        if not DisplayBackend.available:
            return "Unavailable"
        mons = DisplayBackend.list_monitors()
        active = [m for m in mons if not m["disabled"]]
        return f"{len(active)} active" if mons else "No displays"

    def _theme_subtitle(self):
        if not ThemeBackend.available:
            return "Unavailable"
        return ThemeBackend.current_name()

    def refresh_subtitles(self):
        if self.stack.get_visible_child_name() != "list":
            return True
        self.wifi_sub.set_label(self._wifi_subtitle())
        self.hotspot_sub.set_label(self._hotspot_subtitle())
        self.bt_sub.set_label(self._bt_subtitle())
        self.vol_sub.set_label(self._vol_subtitle())
        self.disp_sub.set_label(self._disp_subtitle())
        self.theme_sub.set_label(self._theme_subtitle())
        return True

    def reset_to_list(self):
        self._go_list()
        self.refresh_subtitles()
        if BluetoothBackend.available and BluetoothBackend.powered():
            self._bt_subtitle_async(self.bt_sub)


class ClickOutsideCatcher(Gtk.Window):
    """A separate, fullscreen, fully transparent layer-shell surface that
    sits just below the popup panel, only to catch clicks that land outside
    of it.

    This has to be a second window rather than simply making the panel's
    own window fullscreen: making the panel window itself span the whole
    screen made GTK paint that whole area with its own solid theme
    background (a big gray rectangle covering the monitor) instead of
    staying transparent outside the panel, even with the same "unset"
    background CSS that works fine for the panel-sized window. Keeping the
    panel window sized to its content and adding this window underneath
    avoids that entirely, since this window paints nothing of its own —
    just forwards clicks.
    """

    def __init__(self, panel_window, monitor):
        super().__init__()
        self.set_decorated(False)
        self._panel_window = panel_window

        self.remove_css_class("background")
        self.set_opacity(1.0)

        LayerShell.init_for_window(self)
        LayerShell.set_layer(self, LayerShell.Layer.TOP)
        LayerShell.set_namespace(self, "control-center-catcher")
        LayerShell.set_keyboard_mode(self, LayerShell.KeyboardMode.NONE)
        if monitor is not None:
            LayerShell.set_monitor(self, monitor)
        LayerShell.set_anchor(self, LayerShell.Edge.TOP, True)
        LayerShell.set_anchor(self, LayerShell.Edge.BOTTOM, True)
        LayerShell.set_anchor(self, LayerShell.Edge.LEFT, True)
        LayerShell.set_anchor(self, LayerShell.Edge.RIGHT, True)
        LayerShell.set_exclusive_zone(self, -1)

        self.add_css_class("cc-click-catcher")

        click_ctrl = Gtk.GestureClick()
        click_ctrl.connect("pressed", self._on_click)
        self.add_controller(click_ctrl)

        self._armed = False

    def _on_click(self, *_a):
        if self._armed:
            self._panel_window.hide_panel()

    def set_monitor(self, monitor):
        """Move this click-catcher surface to a different monitor. Must be
        called while the window is unmapped (hidden) — the caller is
        responsible for hiding it first."""
        if monitor is None:
            return
        LayerShell.set_monitor(self, monitor)

    def arm_and_show(self):
        self._armed = False
        self.present()
        GLib.timeout_add(200, self._arm)

    def _arm(self):
        self._armed = True
        return False


class ControlCenterWindow(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app)
        self.set_title("control-center")
        self.set_decorated(False)
        self.remove_css_class("background")
        self.add_css_class("cc-popup-window")

        LayerShell.init_for_window(self)
        LayerShell.set_layer(self, LayerShell.Layer.OVERLAY)
        LayerShell.set_namespace(self, "control-center")
        LayerShell.set_keyboard_mode(self, LayerShell.KeyboardMode.ON_DEMAND)

        monitor = self._pick_monitor()
        self._current_monitor_name = monitor.get_connector() if monitor else None
        if monitor is not None:
            LayerShell.set_monitor(self, monitor)

        LayerShell.set_anchor(self, LayerShell.Edge.TOP, True)
        LayerShell.set_margin(self, LayerShell.Edge.TOP, 60)

        LayerShell.set_exclusive_zone(self, -1)

        self._build_ui()

        key_ctrl = Gtk.EventControllerKey()
        key_ctrl.connect("key-pressed", self._on_key)
        self.add_controller(key_ctrl)

        self._catcher = ClickOutsideCatcher(self, monitor)

        GLib.timeout_add_seconds(1, self._tick_clock)
        GLib.timeout_add_seconds(5, self._tick_subtitles)
        self._tick_clock()

    def _all_monitors(self):
        display = Gdk.Display.get_default()
        monitors = display.get_monitors()
        return [monitors.get_item(i) for i in range(monitors.get_n_items())]

    def _find_monitor(self, name):
        if not name:
            return None
        for m in self._all_monitors():
            if (m.get_connector() or "") == name:
                return m
        return None

    def _pick_monitor(self):
        candidates = self._all_monitors()
        if not candidates:
            return None
        wanted = get_target_monitor() or MONITOR_NAME
        found = self._find_monitor(wanted)
        if found is not None:
            return found
        area = lambda m: m.get_geometry().width * m.get_geometry().height
        return max(candidates, key=area)

    def sync_to_target_monitor(self):
        """Called every time the panel is (re)activated. If the monitor
        that was just clicked differs from the one this panel currently
        lives on, move both this window and its click-catcher there.
        Returns True if a move actually happened."""
        target_name = get_target_monitor()
        if not target_name or target_name == self._current_monitor_name:
            return False
        monitor = self._find_monitor(target_name)
        if monitor is None:
            return False

        was_visible = self.is_visible()
        if was_visible:
            self.set_visible(False)
            self._catcher.set_visible(False)

        LayerShell.set_monitor(self, monitor)
        self._catcher.set_monitor(monitor)
        self._current_monitor_name = target_name
        return True

    def _build_ui(self):
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        outer.set_halign(Gtk.Align.CENTER)
        outer.set_valign(Gtk.Align.START)
        self.set_child(outer)

        panel = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        panel.add_css_class("cc-panel")
        outer.append(panel)

        left = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        left.add_css_class("cc-column")
        left.add_css_class("cc-column-left")
        left.set_size_request(290, -1)
        left.append(MiniCalendar())
        left.append(NowPlaying())
        panel.append(left)

        vsep1 = Gtk.Separator(orientation=Gtk.Orientation.VERTICAL)
        vsep1.add_css_class("cc-vsep")
        panel.append(vsep1)

        center = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        center.add_css_class("cc-column")
        center.add_css_class("cc-column-center")
        center.set_valign(Gtk.Align.CENTER)
        center.set_size_request(265, -1)

        self.time_label = Gtk.Label()
        self.time_label.add_css_class("cc-time-label")
        center.append(self.time_label)

        self.date_label = Gtk.Label()
        self.date_label.add_css_class("cc-date-label")
        center.append(self.date_label)

        power_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        power_row.set_halign(Gtk.Align.CENTER)
        power_row.set_margin_top(24)

        lock_btn = Gtk.Button(label="\uf023")
        lock_btn.add_css_class("cc-power-btn")
        lock_btn.connect("clicked", lambda *_: run_bg(["hyprlock"]))
        power_row.append(lock_btn)

        power_btn = Gtk.Button(label="\uf011")
        power_btn.add_css_class("cc-power-btn")
        power_btn.connect("clicked", lambda *_: run_bg(["wlogout"]))
        power_row.append(power_btn)

        settings_btn = Gtk.Button(label="\uf013")
        settings_btn.add_css_class("cc-power-btn")
        settings_btn.connect("clicked", lambda *_: run_bg(["kitty", "-e", "hotkeys"]))
        power_row.append(settings_btn)

        center.append(power_row)
        panel.append(center)

        vsep2 = Gtk.Separator(orientation=Gtk.Orientation.VERTICAL)
        vsep2.add_css_class("cc-vsep")
        panel.append(vsep2)

        right = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        right.add_css_class("cc-column")
        right.add_css_class("cc-column-right")
        right.set_size_request(330, -1)
        self.quick_settings = QuickSettings()
        right.append(self.quick_settings)
        panel.append(right)

    def _tick_clock(self):
        now = datetime.datetime.now()
        self.time_label.set_label(now.strftime("%H:%M"))
        self.date_label.set_label(now.strftime("%A, %d %B"))
        return True

    def _tick_subtitles(self):
        return self.quick_settings.refresh_subtitles()

    def _on_key(self, _ctrl, keyval, _keycode, _state):
        if keyval == Gdk.KEY_Escape:
            self.hide_panel()
            return True
        return False

    def hide_panel(self):
        self.set_visible(False)
        self._catcher.set_visible(False)

    def show_panel(self):
        self.sync_to_target_monitor()
        self.quick_settings.reset_to_list()
        self._tick_clock()
        self.present()
        self._catcher.arm_and_show()


def load_css():
    css_path = os.path.join(os.path.dirname(__file__), "control-center.css")
    provider = Gtk.CssProvider()
    provider.load_from_path(css_path)
    Gtk.StyleContext.add_provider_for_display(
        Gdk.Display.get_default(),
        provider,
        Gtk.STYLE_PROVIDER_PRIORITY_USER,
    )


def force_dark_theme():
    settings = Gtk.Settings.get_default()
    if settings is not None:
        settings.set_property("gtk-application-prefer-dark-theme", True)


def on_activate(app):
    try:
        win = getattr(app, "_cc_window", None)
        if win is None:
            ensure_state_dir()
            force_dark_theme()
            load_css()
            win = ControlCenterWindow(app)
            app._cc_window = win
            app.hold()
            win.present()
        elif win.is_visible():
            target = get_target_monitor()
            if target and target != win._current_monitor_name:
                win.show_panel()
            else:
                win.hide_panel()
        else:
            win.show_panel()
    except Exception:
        _log(traceback.format_exc())
        raise


def main():
    _log("main() entered")
    app = Gtk.Application(application_id=APP_ID)
    app.connect("activate", on_activate)
    exit_code = app.run(None)
    _log(f"app.run() returned {exit_code}")


if __name__ == "__main__":
    main()
