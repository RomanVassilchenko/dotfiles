{
  config,
  lib,
  pkgs,
  ...
}:
let
  firefoxAddonUrl = slug: "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
in
lib.mkIf config.dotfiles.features.desktop.enable {
  environment.systemPackages = [ pkgs.google-chrome ];

  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = [ pkgs.kdePackages.plasma-browser-integration ];

    preferences = {
      "browser.ai.control.sidebarChatbot" = "blocked";
      "browser.backup.location" = "/home/romanv/Documents/Restore Firefox";
      "browser.backup.scheduled.enabled" = true;
      "browser.contentblocking.category" = "standard";
      "browser.crashReports.unsubmittedCheck.autoSubmit2" = true;
      "browser.ml.chat.enabled" = false;
      "browser.ml.chat.page" = false;
      "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = true;
      "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = true;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
      "browser.newtabpage.activity-stream.showSearch" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.topSitesRows" = 2;
      "browser.search.suggest.enabled" = true;
      "browser.startup.page" = 3;
      "browser.toolbars.bookmarks.visibility" = "always";
      "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
      "browser.urlbar.suggest.quicksuggest.sponsored" = false;
      "dom.forms.autocomplete.formautofill" = true;
      "dom.security.https_only_mode" = true;
      "extensions.activeThemeID" = "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}";
      "extensions.formautofill.creditCards.enabled" = false;
      "general.autoScroll" = true;
      "intl.accept_languages" = "ru,en";
      "intl.regional_prefs.use_os_locales" = true;
      "network.dns.disablePrefetch" = true;
      "network.http.speculative-parallel-limit" = 0;
      "network.prefetch-next" = false;
      "signon.autofillForms" = false;
      "signon.firefoxRelay.feature" = "disabled";
      "signon.generation.enabled" = false;
      "signon.management.page.breach-alerts.enabled" = false;
      "signon.rememberSignons" = false;
      "sidebar.position_start" = false;
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      "sidebar.visibility" = "expand-on-hover";
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };

    policies = {
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "normal_installed";
          install_url = firefoxAddonUrl "ublock-origin";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "normal_installed";
          install_url = firefoxAddonUrl "bitwarden-password-manager";
        };
        "plasma-browser-integration@kde.org" = {
          installation_mode = "force_installed";
          install_url = firefoxAddonUrl "plasma-integration";
        };
        "sponsorBlocker@ajay.app" = {
          installation_mode = "normal_installed";
          install_url = firefoxAddonUrl "sponsorblock";
        };
        "{c84d89d9-a826-4015-957b-affebd9eb603}" = {
          installation_mode = "normal_installed";
          install_url = firefoxAddonUrl "mal-sync";
        };
        "{d3a88b28-681e-43b6-ac3d-22f92ba18818}" = {
          installation_mode = "normal_installed";
          install_url = firefoxAddonUrl "translate-web-pages";
        };
        "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}" = {
          installation_mode = "normal_installed";
          install_url = firefoxAddonUrl "videospeed";
        };
        "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = {
          installation_mode = "normal_installed";
          install_url = firefoxAddonUrl "catppuccin-mocha-mauve-git";
        };
      };
    };
  };
}
