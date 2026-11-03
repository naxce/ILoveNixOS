# Browser Configuration - My Preferences

Read @Docs/settings/BROWSERSrules.md

Last checked: 2026-11-03, Firefox 159.0, Zen 1.24b

## Declarative vs manual

- Declarative, in `Modules/home/browsers.nix` (both browsers unless noted): Betterfox `user.js` + My overrides (Parts II-III), Part I prefs, Part VII and Part VIII (Zen only, Optional list left out), the four extensions from Part IV (installed by policy), Sylvaris live theme script
- Manual: Syncing and account sign-in, Zen "Sync your Spaces across devices", Zen default search engine, extension settings (uBlock filter lists, Bitwarden, DarkReader, SponsorBlock), "Switch to workspace where container is set as default", Zen Mods
- Permissions -> Speaker: no "Block new requests" option exists (Firefox 159 and Zen 1.24b)

## Part I - Settings

- Enhanced Tracking Protection: Custom (CHECKED: Fix major site issues, Cookies - Isolate cross-site cookies, Tracking content - In all windows, Cryptominers, Known fingerprinters, Suspected fingerprinters)
- Additional protections: Tell websites not to sell or share my data CHECKED
- Firefox data collection and use: everything UNCHECKED
- Syncing: ON
- HTTPS-Only Mode in all windows
- DNS over HTTPS: https://base.dns.mullvad.net/dns-query
- Firefox Suggest: UNCHECKED Suggestions from Firefox, Suggestions from sponsors
- Homepage: New windows - Blank Page, New tabs - Blank Page
- AI controls: Block AI enhancements CHECKED, On-device AI Translations: Available
- Passwords: Bitwarden
- Permissions: Location, Camera, Device apps and services, Local network devices, Microphone, Speaker, Notifications, Virtual reality: Block new requests. Autoplay: Block Audio and Video

## Part II - about:config

- media.peerconnection.ice.default_address_only: true
- media.peerconnection.ice.no_host: true
- network.prefetch-next: false
- network.dns.disablePrefetch: true
- network.http.speculative-parallel-limit: 0
- browser.urlbar.speculativeConnect.enabled: false
- browser.safebrowsing.downloads.remote.enabled: false
- network.http.referer.XOriginTrimmingPolicy: 2
- security.tls.enable_0rtt_data: false
- pdfjs.enableScripting: false
- network.IDN_show_punycode: true
- geo.enabled: false

## Part III - user.js

- BetterFox: https://github.com/yokoffing/Betterfox (for Zen, the default user.js too, NOT the one in the zen/ folder)
    How to?:
- Download "user.js" from https://github.com/yokoffing/Betterfox
- Go to "about:profiles" in Firefox/Zen
- Make sure you can see "This is the profile in use and it cannot be deleted."
- Click "Open Folder" in the "Root Directory" line
- Drop "user.js" there
- Restart the browser

### My overrides (paste at the very end of user.js, below "Enter your personal overrides below this line")

- Why: user.js is re-applied on every start, so anything changed only in about:config gets reset if Betterfox also sets it. Keeping Part II here makes it permanent and survives Betterfox updates.
- Betterfox sets ETP to Strict (`browser.contentblocking.category = "strict"`). To keep my Custom ETP from Part I, the first line below is required. (Alternative: delete it and accept Strict - it also strips tracking parameters from links.)
- Betterfox saves the session every 60 s; the second line restores Firefox's 15 s so Zen loses fewer tabs after a crash.

```
user_pref("browser.contentblocking.category", "custom");
user_pref("browser.sessionstore.interval", 15000);
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("media.peerconnection.ice.no_host", true);
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("browser.urlbar.speculativeConnect.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);
user_pref("security.tls.enable_0rtt_data", false);
user_pref("pdfjs.enableScripting", false);
user_pref("network.IDN_show_punycode", true);
user_pref("geo.enabled", false);
```

### Check after restart

- about:config -> `browser.contentblocking.category` shows my value (bold = set by user.js)
- Zen: Settings -> General -> Startup -> "Open previous windows and tabs" still CHECKED
- Updating Betterfox: close the browser, replace user.js, paste "My overrides" again
- Removing user.js does NOT undo its prefs (they stay in prefs.js) - restore a profile backup or reset prefs one by one in about:config

## Part IV - Extensions

- uBlock Origin
- Settings -> Filter lists:
- Privacy: CHECKED EasyPrivacy, AdGuard/uBO – URL Tracking Protection
- Cookie notices: CHECKED AdGuard/uBO – Cookie Notices: CHECKED AdGuard – Cookie Notices, uBlock filters – Cookie Notices 
- Bitwarden Password Manager
- DarkReader
- SponsorBlock

### Do NOT install

- ClearURLs - redundant (uBO URL Tracking Protection list + Firefox query stripping)
- LocalCDN / Decentraleyes - redundant (Firefox partitions the cache per site) and can break sites
- Privacy Badger, Ghostery, canvas/anti-fingerprint extensions - overlap with ETP/uBO, make me more unique
- Rule: every extension sees every page I open - keep the list short

### Firefox side for Bitwarden

- Settings -> Passwords: UNCHECKED Ask to save passwords, Fill usernames and passwords automatically
- Autofill: UNCHECKED Save and fill addresses, Save and fill payment methods

## Part V - Zen privacy

- Parts I-IV apply to Zen as well (same Privacy & Security pane, same about:config, same user.js steps - but in Zen's own about:profiles)
- Settings -> Search -> Default Search Engine: change from Google
- Settings -> Sync -> Sync your Spaces across devices: ON, Include unpinned tabs: UNCHECKED
- Settings -> General -> Language: keep English (a rare language makes me easier to fingerprint)
- Zen Mods: official store only (CSS only, reviewed). NO Sine (its mods run JavaScript with full browser access)
- Share (Space/folder/split/Boost links): don't use for anything sensitive (goes through share.zen-browser.app)
- Known limit: no Widevine DRM - Netflix-type streaming doesn't play

### Never do in Zen

- arkenfox user.js - its startup/clear-on-shutdown settings wipe unpinned tabs in Spaces
- privacy.resistFingerprinting: true - forced light mode, grey letterbox bars, breaks Zen's layout
- privacy.firstparty.isolate: true - legacy, replaced by cookie isolation, breaks sites
- browser.safebrowsing.malware.enabled / phishing.enabled: false - removes malware protection, no privacy gain
- Settings -> General -> Startup -> UNCHECK "Open previous windows and tabs" - Zen then restores ONLY pinned tabs
- Settings -> Privacy & Security -> History -> "Always use private browsing mode" - same effect
- Copy-pasted "Zen optimization" lists from Reddit - known to cause freezes
- Unofficial "Betterfox for Zen" forks (Better Zen, TeamDominant) - outdated / unmaintained

## Part VI - Zen features (keep / drop)

- Spaces: KEEP - separate tab sets (Work/Personal), each with own pinned tabs, folders, icon, theme. Can't be disabled; one Space = effectively off
- Space Profile (container): KEEP if I want separate logins per Space (own cookies), otherwise ignore
- Space Routing: KEEP if I use 2+ Spaces - rules sending links (e.g. github.com) to a chosen Space. Set in Library
- Essentials: KEEP - up to 12 icon tiles shared by all Spaces, for daily web apps. Double-click = back to home URL
- Pinned tabs + reset: KEEP - per-Space tabs that remember their URL, reset button brings them back
- Close Tab Shortcut Behavior: CHOOSE - default "Reset, unload and switch" (Ctrl+W doesn't close pinned tabs); "Close tab" = normal Firefox behaviour
- Folders: KEEP - named tab groups (up to 5 levels), "Unload All Tabs", "Convert to Space"
- Live Folders: OPTIONAL - auto-filled from RSS or GitHub issues/PRs; makes background requests
- Glance: KEEP - Alt+click opens a link in a floating preview, Ctrl+O turns it into a tab. Change trigger to Shift if Alt+click conflicts
- Split View: KEEP - up to 4 tabs side by side (grid/vertical/horizontal). Disable drag-to-split if it triggers by accident
- Compact Mode: KEEP - Ctrl+S hides sidebar/toolbar, shown on hover or Ctrl+Alt+S
- Browser Layout: Only Sidebar (cleanest) / Sidebar and Top Toolbar (classic URL bar + extension icons) / Collapsed Sidebar
- Floating URL bar instead of new tab page: KEEP (Ctrl+T) - matches my Blank Page setup
- Command Bar: KEEP - Ctrl+T then Tab lists ~38 actions; "` " (backtick + space) searches only this Space's tabs
- Clear button: KEEP - Ctrl+Shift+K closes all unpinned tabs in the Space (with Undo). Zen has no Arc-style auto-archive
- Library: KEEP - Alt+Shift+L, History, closed tabs, Downloads, Boosts, Spaces, Space Routing
- Boosts: KEEP - per-site colors/fonts, Zap (remove page elements), custom CSS, Smart Invert dark mode, Focus. Can replace DarkReader in Zen
- Window Sync: KEEP - all windows show the same Spaces. Ctrl+Shift+N = temporary unsynced window, its tabs are NOT restored
- Cross-device Spaces sync: KEEP (Syncing ON) - back up the profile before first sync, it MERGES Spaces from both machines
- Share: OFF for sensitive stuff
- Gradient themes / transparency: OPTIONAL - per-Space colors; turn off on a weak GPU or if pages look see-through
- Zen Mods: OPTIONAL - official CSS mods, auto-update. If UI breaks after an update -> "Disable all mods"
- Media controls: KEEP - sidebar player + mic/camera mute
- Auto Picture-in-Picture: OPTIONAL - video pops out when switching tabs
- Tab rename / custom icon: KEEP - double-click title, right-click for icon
- Drag window from web pages: OPTIONAL - turn off if selecting text near the top moves the window
- PDF merging, Arc/Dia import: built-in tools, nothing to configure
- Removed (don't look for them): sidebar web panels, disabling Spaces, shortcut editor in Settings, profile switcher button, horizontal tabs, zen.tab-unloader.* prefs

## Part VII - Zen Settings

### Look and Feel

- Browser Layout: Only Sidebar
- Vertical Tabs: Show New Tab Button on Tab List CHECKED, Move the new tab button to the top CHECKED
- Show in compact view: toolbar popup when switching tabs UNCHECKED, Allow dragging the window from web pages CHECKED
- Glance: Enable Glance CHECKED, Trigger method: Alt (Shift if Alt conflicts)

### Tab Management

- Sync only pinned tabs in workspaces: UNCHECKED
- Hide the default container indicator: CHECKED
- Switch to workspace where container is set as default: CHECKED if Spaces have containers
- Close tab and switch to its owner tab when going back with no history: CHECKED
- Ignore pending tabs in Ctrl+Tab: CHECKED
- Ctrl+Tab cycles only within Essentials or Workspace: UNCHECKED
- Select recently used tab on close: CHECKED
- Restore pinned tabs to their originally pinned URL on startup: CHECKED (reported to be unreliable)
- Container-specific essentials: CHECKED
- Close Tab Shortcut Behavior: Reset, unload and switch (or "Close tab")

### Other panes

- Keyboard Shortcuts: opens about:keyboard (edit shortcuts there)
- Zen Mods: Export after every change (backup)
- General -> Startup: Open previous windows and tabs CHECKED, Continue where you left off CHECKED

## Part VIII - Zen about:config

- zen.view.compact.hide-toolbar: true (Compact Mode hides both bars)
- zen.view.compact.animate-sidebar: false (snappier)
- zen.workspaces.switch-animation-duration: 0 (instant Space switching)
- zen.theme.content-element-separation: 0 (page edge to edge; default 8)
- zen.tabs.ctrl-tab.ignore-pending-tabs: true
- zen.spaces-sync.normal-tabs: false (KEEP false - privacy)
- Optional:
    - zen.view.compact.show-sidebar-and-toolbar-on-hover: false (sidebar only via Ctrl+Alt+S)
    - zen.glance.activation-method: shift
    - zen.tabs.vertical.right-side: true (sidebar on the right)
    - zen.view.window.scheme: 0 dark / 1 light / 2 system
    - zen.tabs.essentials.max: 12 (raise for more Essentials)
    - zen.urlbar.replace-newtab: false (real new tab page instead of floating URL bar)
    - zen.view.show-clear-tabs-button: false
    - zen.splitView.enable-tab-drop / zen.splitView.enable-drag-over-split: false (no accidental splits)
    - toolkit.tabbox.switchByScrolling: true (mouse wheel switches tabs)
    - browser.tabs.allow_transparent_browser: false (fixes see-through pages)
- Dead prefs from old docs (don't create): zen.tabs.dim-pending, zen.tab-unloader.*, zen.keyboard.shortcuts.enabled, zen.view.compact.color-sidebar, zen.view.gray-out-inactive-windows

## Part IX - Zen shortcuts (Windows/Linux; macOS: Ctrl -> Cmd, Alt -> Option)

- Final word is about:keyboard on my machine
- Ctrl+S: Compact Mode
- Ctrl+Alt+S: show sidebar in Compact Mode
- Ctrl+Alt+Left/Right: previous/next Space
- Alt+1...0: jump to Space 1-10 (verify in about:keyboard)
- Ctrl+Shift+K: close all unpinned tabs (Clear)
- Ctrl+Alt+G / V / H: split grid / vertical / horizontal
- Ctrl+Alt+U: unsplit
- Alt+Shift+L: Library
- Alt+click link: Glance; Ctrl+O: Glance -> full tab
- Alt+click tab: split with current tab
- Ctrl+Shift+D: pin / unpin tab
- Ctrl+Shift+C: copy URL; Ctrl+Alt+Shift+C: copy URL as Markdown
- Ctrl+Shift+N: temporary unsynced window
- Ctrl+T then Tab: command list
- Moved from Firefox: Save Page As = Ctrl+Alt+S, Inspect = Ctrl+Shift+L (Ctrl+S, Ctrl+O, Ctrl+Shift+D, Ctrl+Shift+C now do Zen things)
- Bind myself in about:keyboard: Create Space, Duplicate Tab, Reset Pinned Tab

## Part X - Backup (Zen)

- Profile folder: about:profiles -> Root Directory -> Open Folder
    - Windows: %APPDATA%\zen\Profiles\
    - macOS: ~/Library/Application Support/zen/Profiles/
    - Linux: ~/.zen/ or ~/.config/zen/
- How: quit Zen (Ctrl+Q), copy the WHOLE profile folder, Settings -> Zen Mods -> Export
- Key files: zen-sessions.jsonlz4 (Spaces + tabs), zen-sessions-backup/ (auto, up to 20, every ~3 h), zen-themes.json + chrome/ (mods), prefs.js + user.js
- When: before Betterfox changes, before turning on Sync on a 2nd machine, before big Zen updates
- Restore lost tabs: quit Zen -> copy a file from zen-sessions-backup/ to the profile folder -> rename to zen-sessions.jsonlz4 -> start Zen (try older backups if needed)
- Always quit with Ctrl+Q, not by closing windows
- UI broken after update: Settings -> Zen Mods -> Disable all mods; if Zen won't start, move zen-themes.json out of the profile folder

## Part XI - Routine

- After every Firefox major update (~every 4 weeks): re-check Settings -> Firefox Suggest, Home, AI controls, Data collection
- Betterfox update: replace user.js, re-paste My overrides
- Every few weeks: copy the Zen profile folder
