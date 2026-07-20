#!/usr/bin/env python3
"""
nixgreet - a minimal greetd frontend that visually mirrors hyprlock.conf 1:1,
with an added session picker (the one thing hyprlock doesn't need, since it
only unlocks an already-running session).

Layout mirrors hyprlock.conf's labels/image/input-field positions exactly:
  - time label       -> position 0, 140   (halign/valign center)
  - date label        -> position 0, 40
  - avatar image       -> position 0, -30
  - username label      -> position 0, -95
  - input-field (password) -> position 0, -155
  - session picker (new)  -> just above the login button
  - hint label         -> position 0, -215

Talks to greetd over its unix socket using the JSON IPC protocol described in
`man 7 greetd-ipc`.
"""

import sys
import traceback

LOG_PATH = "/tmp/nixgreet.log"


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
_log(f"--- nixgreet starting, python={sys.version}, argv={sys.argv} ---")

try:
    import gi

    gi.require_version("Gtk", "4.0")
    gi.require_version("Gtk4LayerShell", "1.0")

    from gi.repository import Gdk, GLib, Gtk
    from gi.repository import Gtk4LayerShell as LayerShell
except Exception:
    _log(traceback.format_exc())
    raise

import datetime
import getpass
import json
import os
import pwd
import socket
import struct

GREETD_SOCK = os.environ.get("GREETD_SOCK")
WALLPAPER_PATH = os.environ.get("NIXGREET_WALLPAPER", "/etc/greetd/wallpaper.png")
SESSIONS_DIR = "/etc/greetd/environments"
PRIMARY_MONITOR_NAME = os.environ.get("NIXGREET_MONITOR")


def pick_primary_monitor(display):
    """Pick which output the greeter should appear on.

    On a multi-monitor setup, gtk4-layer-shell maps the surface to
    whichever output the compositor happens to choose if we don't say
    otherwise - not necessarily the "main" one the user actually looks
    at. If NIXGREET_MONITOR names a connector (matching hyprland's
    monitors.conf naming, e.g. "DP-6"), use that; otherwise fall back to
    the monitor with the largest pixel area, which is normally the main
    display in these mixed-resolution setups.
    """
    monitors = display.get_monitors()
    n = monitors.get_n_items()
    if n == 0:
        return None

    candidates = [monitors.get_item(i) for i in range(n)]

    if PRIMARY_MONITOR_NAME:
        for m in candidates:
            connector = m.get_connector() or ""
            if connector == PRIMARY_MONITOR_NAME:
                return m
        _log(
            f"NIXGREET_MONITOR={PRIMARY_MONITOR_NAME!r} not found among "
            f"{[m.get_connector() for m in candidates]}, falling back to largest"
        )

    def area(m):
        geo = m.get_geometry()
        return geo.width * geo.height

    return max(candidates, key=area)


def detect_login_user():
    """Pick the user to log in as.

    The greeter process itself runs as the unprivileged "greeter" system
    account, so getpass.getuser() would show "greeter" instead of the
    actual person using the machine. Mirror what regreet/most greeters do:
    list normal (human) accounts from /etc/passwd - those with a login
    shell and a UID in the normal range - and use the first one.
    """
    candidates = []
    for entry in pwd.getpwall():
        if entry.pw_uid < 1000:
            continue
        if entry.pw_shell in ("/usr/sbin/nologin", "/sbin/nologin", "/bin/false", ""):
            continue
        if entry.pw_name in ("greeter", "nobody"):
            continue
        candidates.append(entry.pw_name)
    if candidates:
        return sorted(candidates)[0]
    return getpass.getuser()


def prepare_background(src_path):
    """Blur the wallpaper once at startup to approximate hyprlock's
    blur_passes=3 / blur_size=7 (GTK4 CSS has no backdrop-filter/blur, so
    this pre-processes the image itself instead). Cached in /tmp so repeat
    greeter launches don't reprocess it every time.
    """
    cache_path = "/tmp/nixgreet-bg-blurred.png"
    try:
        src_mtime = os.path.getmtime(src_path)
        if os.path.exists(cache_path) and os.path.getmtime(cache_path) >= src_mtime:
            return cache_path
    except OSError:
        pass

    try:
        from PIL import Image, ImageEnhance, ImageFilter

        img = Image.open(src_path).convert("RGB")
        for _ in range(3):
            img = img.filter(ImageFilter.GaussianBlur(radius=7))
        img = ImageEnhance.Contrast(img).enhance(0.9)
        img = ImageEnhance.Brightness(img).enhance(0.65)
        img.save(cache_path, "PNG")
        return cache_path
    except Exception:
        _log(traceback.format_exc())
        return src_path


LOGIN_USER = detect_login_user()


def read_sessions():
    """Read the list of available sessions.

    Each line is either just an exec command ("start-hyprland") or, when a
    friendlier name should be shown than the actual command greetd needs to
    run, "Display Name|exec-command" (e.g. "Hyprland|start-hyprland").
    Falls back to a single Hyprland entry if the file is missing/empty.

    Returns a list of (display_name, exec_command) tuples.
    """
    try:
        with open(SESSIONS_DIR) as f:
            lines = [line.strip() for line in f if line.strip()]
    except OSError:
        lines = []

    sessions = []
    for line in lines:
        if "|" in line:
            name, _, cmd = line.partition("|")
            name, cmd = name.strip(), cmd.strip()
            if name and cmd:
                sessions.append((name, cmd))
        elif line:
            sessions.append((line, line))

    if sessions:
        return sessions
    return [("Hyprland", "start-hyprland")]


class GreetdClient:
    """Tiny synchronous client for the greetd IPC protocol over a unix socket."""

    def __init__(self, sock_path):
        self.sock_path = sock_path
        self.sock = None
        if sock_path:
            self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            self.sock.connect(sock_path)

    def _send(self, obj):
        data = json.dumps(obj).encode("utf-8")
        self.sock.sendall(struct.pack("I", len(data)) + data)

    def _recv(self):
        header = self._recv_exact(4)
        (length,) = struct.unpack("I", header)
        data = self._recv_exact(length)
        return json.loads(data.decode("utf-8"))

    def _recv_exact(self, n):
        buf = b""
        while len(buf) < n:
            chunk = self.sock.recv(n - len(buf))
            if not chunk:
                raise ConnectionError("greetd closed the connection")
            buf += chunk
        return buf

    def create_session(self, username):
        self._send({"type": "create_session", "username": username})
        return self._recv()

    def post_auth_message_response(self, response):
        self._send({"type": "post_auth_message_response", "response": response})
        return self._recv()

    def start_session(self, cmd, env=None):
        self._send({"type": "start_session", "cmd": cmd, "env": env or []})
        return self._recv()

    def cancel_session(self):
        self._send({"type": "cancel_session"})
        return self._recv()


class NixGreetWindow(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app)
        self.set_title("nixgreet")
        self.set_decorated(False)

        self.client = GreetdClient(GREETD_SOCK) if GREETD_SOCK else None
        self.auth_stage = "username"
        self.sessions = read_sessions()

        LayerShell.init_for_window(self)
        LayerShell.set_layer(self, LayerShell.Layer.OVERLAY)
        LayerShell.set_exclusive_zone(self, -1)

        monitor = pick_primary_monitor(Gdk.Display.get_default())
        if monitor is not None:
            LayerShell.set_monitor(self, monitor)
            self.target_geometry = monitor.get_geometry()
        else:
            _log("no monitors found via Gdk.Display, letting compositor choose")
            self.target_geometry = None

        for edge in (
            LayerShell.Edge.TOP,
            LayerShell.Edge.BOTTOM,
            LayerShell.Edge.LEFT,
            LayerShell.Edge.RIGHT,
        ):
            LayerShell.set_anchor(self, edge, True)
        LayerShell.set_keyboard_mode(self, LayerShell.KeyboardMode.EXCLUSIVE)

        self._build_ui()
        self._tick_clock()
        GLib.timeout_add_seconds(1, self._tick_clock)

    def _build_ui(self):
        overlay = Gtk.Overlay()
        overlay.set_hexpand(True)
        overlay.set_vexpand(True)
        overlay.set_halign(Gtk.Align.FILL)
        overlay.set_valign(Gtk.Align.FILL)
        self.set_child(overlay)

        bg = Gtk.Picture()
        bg.set_filename(prepare_background(WALLPAPER_PATH))
        bg.set_content_fit(Gtk.ContentFit.COVER)
        bg.set_hexpand(True)
        bg.set_vexpand(True)
        bg.set_halign(Gtk.Align.FILL)
        bg.set_valign(Gtk.Align.FILL)
        overlay.set_child(bg)

        darken = Gtk.Box()
        darken.add_css_class("darken")
        darken.set_hexpand(True)
        darken.set_vexpand(True)
        darken.set_halign(Gtk.Align.FILL)
        darken.set_valign(Gtk.Align.FILL)
        overlay.add_overlay(darken)

        center_wrapper = Gtk.Box()
        center_wrapper.set_hexpand(True)
        center_wrapper.set_vexpand(True)
        center_wrapper.set_halign(Gtk.Align.FILL)
        center_wrapper.set_valign(Gtk.Align.FILL)
        overlay.add_overlay(center_wrapper)

        center_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        center_box.set_halign(Gtk.Align.CENTER)
        center_box.set_valign(Gtk.Align.CENTER)
        center_box.set_spacing(0)
        center_wrapper.append(center_box)

        if self.target_geometry is not None:
            geo = self.target_geometry
            self.connect(
                "realize",
                lambda *_a: GLib.idle_add(
                    self._reposition_for_monitor, center_box, geo
                ),
            )

        self.time_label = Gtk.Label()
        self.time_label.add_css_class("time-label")
        center_box.append(self.time_label)

        self.date_label = Gtk.Label()
        self.date_label.add_css_class("date-label")
        self.date_label.set_margin_bottom(46)
        center_box.append(self.date_label)

        avatar = Gtk.DrawingArea()
        avatar.set_content_width(96)
        avatar.set_content_height(96)
        avatar.add_css_class("avatar")
        initial = LOGIN_USER[:1].upper() if LOGIN_USER else "?"
        avatar.set_draw_func(self._draw_avatar, initial)
        center_box.append(avatar)

        self.username_label = Gtk.Label(label=LOGIN_USER)
        self.username_label.add_css_class("username-label")
        self.username_label.set_margin_top(10)
        self.username_label.set_margin_bottom(14)
        center_box.append(self.username_label)

        self.entry = Gtk.PasswordEntry()
        self.entry.set_show_peek_icon(False)
        self.entry.add_css_class("password-entry")
        self.entry.set_property("placeholder-text", "Enter password")
        self.entry.set_size_request(260, 46)
        self.entry.connect("activate", self._on_entry_activate)
        center_box.append(self.entry)

        session_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        session_row.set_halign(Gtk.Align.CENTER)
        session_row.set_margin_top(14)

        self.selected_session_index = 0

        self.session_button = Gtk.MenuButton()
        self.session_button.add_css_class("session-dropdown")
        self.session_button.set_size_request(180, 40)

        button_content = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        button_content.set_halign(Gtk.Align.FILL)
        self.session_label = Gtk.Label(label=self.sessions[0][0])
        self.session_label.add_css_class("session-dropdown-label")
        self.session_label.set_halign(Gtk.Align.START)
        self.session_label.set_hexpand(True)
        button_content.append(self.session_label)

        arrow = Gtk.Label(label="\u25be")
        arrow.add_css_class("session-dropdown-arrow")
        button_content.append(arrow)
        self.session_button.set_child(button_content)

        self.session_popover = Gtk.Popover()
        self.session_popover.add_css_class("session-popover")
        self.session_popover.set_has_arrow(False)
        self.session_button.set_popover(self.session_popover)

        session_list = Gtk.ListBox()
        session_list.add_css_class("session-list")
        session_list.set_selection_mode(Gtk.SelectionMode.SINGLE)
        for i, (name, _cmd) in enumerate(self.sessions):
            row = Gtk.ListBoxRow()
            row.add_css_class("session-list-row")
            lbl = Gtk.Label(label=name)
            lbl.set_halign(Gtk.Align.START)
            row.set_child(lbl)
            session_list.append(row)
        session_list.select_row(session_list.get_row_at_index(0))
        session_list.connect("row-activated", self._on_session_selected)
        self.session_popover.set_child(session_list)

        session_row.append(self.session_button)
        center_box.append(session_row)

        self.hint_label = Gtk.Label(label="Press Enter to log in")
        self.hint_label.add_css_class("hint-label")
        self.hint_label.set_margin_top(14)
        center_box.append(self.hint_label)

        self.entry.grab_focus()

    def _reposition_for_monitor(self, center_box, geo):
        """Nudge center_box so it's centered within `geo` (this window's
        target monitor) rather than the whole surface, in case cage handed
        us a surface spanning more than just that monitor.

        cage can allocate its client surface across the bounding box of
        every connected monitor when there's more than one, so "centered
        in the window" and "centered on the monitor we picked" aren't
        necessarily the same rectangle. geo.x/geo.y/width/height describe
        the target monitor in the *global* multi-monitor coordinate space.
        self.get_width()/get_height() only tell us the surface's own
        size, which could be either that same global bounding box, or
        already just the target monitor's own size if the compositor
        constrained it via set_monitor()+anchoring — mixing the two
        coordinate spaces (as an earlier version of this code did) produces
        a bogus, too-small offset. Detect which case we're in by comparing
        sizes instead of assuming.
        """
        surface_w = self.get_width()
        surface_h = self.get_height()
        if surface_w <= 0 or surface_h <= 0:
            return GLib.SOURCE_CONTINUE

        _log(
            f"reposition: surface={surface_w}x{surface_h} "
            f"target_geo=({geo.x},{geo.y},{geo.width},{geo.height})"
        )

        if surface_w == geo.width and surface_h == geo.height:
            center_box.set_margin_start(0)
            center_box.set_margin_end(0)
            center_box.set_margin_top(0)
            center_box.set_margin_bottom(0)
            return GLib.SOURCE_REMOVE

        monitor_center_x = geo.x + geo.width / 2
        monitor_center_y = geo.y + geo.height / 2
        surface_center_x = surface_w / 2
        surface_center_y = surface_h / 2

        offset_x = round(monitor_center_x - surface_center_x)
        offset_y = round(monitor_center_y - surface_center_y)

        center_box.set_margin_start(max(0, offset_x * 2))
        center_box.set_margin_end(max(0, -offset_x * 2))
        center_box.set_margin_top(max(0, offset_y * 2))
        center_box.set_margin_bottom(max(0, -offset_y * 2))
        return GLib.SOURCE_REMOVE

    def _draw_avatar(self, area, cr, width, height, initial):
        import cairo as _cairo

        cx, cy, r = width / 2, height / 2, min(width, height) / 2 - 1

        cr.arc(cx, cy, r, 0, 2 * 3.14159265)
        cr.set_source_rgba(1, 1, 1, 0.08)
        cr.fill_preserve()

        cr.set_source_rgba(1, 1, 1, 0.9)
        cr.set_line_width(2)
        cr.stroke()

        cr.select_font_face("Inter", _cairo.FONT_SLANT_NORMAL, _cairo.FONT_WEIGHT_BOLD)
        cr.set_font_size(36)
        cr.set_source_rgba(1, 1, 1, 0.9)
        extents = cr.text_extents(initial)
        cr.move_to(
            cx - extents.width / 2 - extents.x_bearing,
            cy - extents.height / 2 - extents.y_bearing,
        )
        cr.show_text(initial)

    def _on_session_selected(self, listbox, row):
        index = row.get_index()
        self.selected_session_index = index
        self.session_label.set_text(self.sessions[index][0])
        self.session_popover.popdown()

    def _tick_clock(self):
        now = datetime.datetime.now()
        self.time_label.set_text(now.strftime("%H:%M"))
        self.date_label.set_text(now.strftime("%A, %d %B"))
        return True

    def _on_entry_activate(self, _entry):
        password = self.entry.get_text()
        username = LOGIN_USER
        _display_name, session = self.sessions[self.selected_session_index]

        if self.client is None:
            self.hint_label.set_text("No greetd socket found")
            self.hint_label.add_css_class("error")
            return

        try:
            resp = self.client.create_session(username)
            if resp.get("type") == "auth_message":
                resp = self.client.post_auth_message_response(password)

            if resp.get("type") == "success":
                self.client.start_session([session])
                self.get_application().quit()
            else:
                self.entry.set_text("")
                self.hint_label.set_text("Incorrect password")
                self.hint_label.add_css_class("error")
                self.client.cancel_session()
        except Exception as exc:
            self.hint_label.set_text(f"Login error: {exc}")
            self.hint_label.add_css_class("error")


def load_css():
    css_path = os.path.join(os.path.dirname(__file__), "nixgreet.css")
    provider = Gtk.CssProvider()
    provider.load_from_path(css_path)
    Gtk.StyleContext.add_provider_for_display(
        Gdk.Display.get_default(),
        provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
    )


def on_activate(app):
    try:
        load_css()
        win = NixGreetWindow(app)
        win.present()
    except Exception:
        _log(traceback.format_exc())
        raise


def main():
    _log("main() entered")
    app = Gtk.Application(application_id="dev.nixos.nixgreet")
    app.connect("activate", on_activate)
    exit_code = app.run(None)
    _log(f"app.run() returned {exit_code}")


if __name__ == "__main__":
    main()
