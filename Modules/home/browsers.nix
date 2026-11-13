{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  sylvarisScript = "${
    inputs.frepo.packages.${pkgs.stdenv.hostPlatform.system}.sylvaris
  }/share/sylvaris/helpers/browser.js";
  mullvad = "https://base.dns.mullvad.net/dns-query";

  extensions =
    lib.mapAttrs
      (_: slug: {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      })
      {
        "uBlock0@raymondhill.net" = "ublock-origin";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
        "addon@darkreader.org" = "darkreader";
        "sponsorBlocker@ajay.app" = "sponsorblock";
      };

  policies.ExtensionSettings = extensions;

  shared = {
    "browser.contentblocking.category" = "custom";
    "browser.sessionstore.interval" = 15000;
    "media.peerconnection.ice.default_address_only" = true;
    "media.peerconnection.ice.no_host" = true;
    "network.prefetch-next" = false;
    "network.dns.disablePrefetch" = true;
    "network.http.speculative-parallel-limit" = 0;
    "browser.urlbar.speculativeConnect.enabled" = false;
    "browser.safebrowsing.downloads.remote.enabled" = false;
    "network.http.referer.XOriginTrimmingPolicy" = 2;
    "security.tls.enable_0rtt_data" = false;
    "pdfjs.enableScripting" = false;
    "network.IDN_show_punycode" = true;
    "geo.enabled" = false;

    "privacy.trackingprotection.allow_list.baseline.enabled" = true;
    "network.cookie.cookieBehavior" = 5;
    "network.cookie.cookieBehavior.pbmode" = 5;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.pbmode.enabled" = true;
    "privacy.trackingprotection.cryptomining.enabled" = true;
    "privacy.trackingprotection.fingerprinting.enabled" = true;
    "privacy.fingerprintingProtection" = true;
    "privacy.fingerprintingProtection.pbmode" = true;
    "privacy.globalprivacycontrol.enabled" = true;

    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.usage.uploadEnabled" = false;
    "app.shield.optoutstudies.enabled" = false;
    "browser.discovery.enabled" = false;
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

    "dom.security.https_only_mode" = true;
    "network.trr.mode" = 2;
    "network.trr.uri" = mullvad;
    "network.trr.custom_uri" = mullvad;

    "browser.urlbar.suggest.quicksuggest.all" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;

    "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
    "browser.newtabpage.enabled" = false;

    "browser.ai.control.default" = "blocked";
    "extensions.ml.enabled" = false;
    "browser.ai.control.translations" = "available";

    "signon.rememberSignons" = false;
    "signon.autofillForms" = false;
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.creditCards.enabled" = false;

    "permissions.default.geo" = 2;
    "permissions.default.camera" = 2;
    "permissions.default.loopback-network" = 2;
    "permissions.default.local-network" = 2;
    "permissions.default.microphone" = 2;
    "permissions.default.desktop-notification" = 2;
    "permissions.default.xr" = 2;
    "media.autoplay.default" = 5;
  };

  zenOnly = {
    "browser.startup.page" = 3;
    "zen.workspaces.continue-where-left-off" = true;

    "zen.view.use-single-toolbar" = true;
    "zen.view.sidebar-expanded" = true;
    "zen.tabs.show-newtab-vertical" = true;
    "zen.view.show-newtab-button-top" = true;
    "zen.view.compact.toolbar-flash-popup" = false;
    "zen.view.drag-window-from-content" = true;
    "zen.glance.enabled" = true;
    "zen.glance.activation-method" = "alt";

    "zen.window-sync.sync-only-pinned-tabs" = false;
    "zen.workspaces.hide-default-container-indicator" = true;
    "zen.tabs.close-on-back-with-no-history" = true;
    "zen.tabs.ctrl-tab.ignore-essential-tabs" = false;
    "zen.tabs.select-recently-used-on-close" = true;
    "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = true;
    "zen.workspaces.separate-essentials" = true;
    "zen.pinned-tab-manager.close-shortcut-behavior" = "reset-unload-switch";

    "zen.view.compact.hide-toolbar" = true;
    "zen.view.compact.animate-sidebar" = false;
    "zen.workspaces.switch-animation-duration" = 0;
    "zen.theme.content-element-separation" = 0;
    "zen.tabs.ctrl-tab.ignore-pending-tabs" = true;
    "zen.spaces-sync.normal-tabs" = false;
  };

  userJs =
    prefs:
    builtins.readFile "${inputs.betterfox}/user.js"
    + "\n"
    + lib.concatStrings (
      lib.mapAttrsToList (
        name: value: "user_pref(${builtins.toJSON name}, ${builtins.toJSON value});\n"
      ) prefs
    );

  firefox = pkgs.firefox.override {
    extraPolicies = policies;
    extraPrefsFiles = [ sylvarisScript ];
    extraAutoConfig = ''pref("general.config.sandbox_enabled", false);'';
  };

  zenPackages = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system};
  zenUnwrapped = (zenPackages.beta-unwrapped.override { inherit policies; }).overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      for lib in "$out"/lib/zen-bin-*; do
        chmod -R u+w "$lib/defaults"
        { echo "//"; cat ${sylvarisScript}; } > "$lib/sylvaris.cfg"
        printf '%s\n' 'pref("general.config.filename", "sylvaris.cfg");' 'pref("general.config.obscure_value", 0);' 'pref("general.config.sandbox_enabled", false);' > "$lib/defaults/pref/sylvaris.js"
      done
    '';
  });
  zen = import "${inputs.zen-browser}/wrap-zen.nix" pkgs.wrapFirefox zenUnwrapped {
    icon = "zen-browser";
  };
in
{
  home.packages = [
    firefox
    zen
  ];

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "text/html"
    "application/xhtml+xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ] (_: "zen-beta.desktop");

  home.file.".config/mozilla/firefox/8vr9b888.default/user.js" = {
    text = userJs shared;
    force = true;
  };

  home.file.".config/zen/dkdj37em.Default Profile/user.js" = {
    text = userJs (shared // zenOnly);
    force = true;
  };
}
