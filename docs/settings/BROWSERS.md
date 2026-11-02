# Browser Configuration - My Preferences

Read @docs/settings/BROWSERSrules.md

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

## Part IV - Extensions

- uBlock Origin
  - Settings -> Filter lists:
    - Privacy: CHECKED EasyPrivacy, AdGuard/uBO – URL Tracking Protection
    - Cookie notices: CHECKED AdGuard/uBO – Cookie Notices: CHECKED AdGuard – Cookie Notices, uBlock filters – Cookie Notices 