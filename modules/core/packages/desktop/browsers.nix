{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.dotfiles.features.desktop.enable {
  environment.systemPackages = [ pkgs.google-chrome ];

  programs.helium = {
    enable = true;
    package = inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.helium;
    flags = [
      "--ozone-platform-hint=auto"
      "--enable-features=TouchpadOverscrollHistoryNavigation"
      "--accept-lang=en,ru"
    ];
    policies = {
      BrowserSignin = 0;
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderKeyword = "google.com";
      DefaultSearchProviderName = "Google";
      DefaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}";
      DefaultSearchProviderSuggestURL = "https://www.google.com/complete/search?client=chrome&q={searchTerms}";
      DefaultBrowserSettingEnabled = false;
      HttpsOnlyMode = "force_enabled";
      MetricsReportingEnabled = false;
      PasswordManagerEnabled = false;
      PrivacySandboxAdMeasurementEnabled = false;
      PrivacySandboxAdTopicsEnabled = false;
      PrivacySandboxSiteEnabledAdsEnabled = false;
      RestoreOnStartup = 1;
      SearchSuggestEnabled = true;
      SpellCheckServiceEnabled = false;
      SpellcheckEnabled = true;
      SpellcheckLanguage = [
        "en"
        "ru"
      ];
      SpellcheckLanguageBlocklist = [ ];
      SyncDisabled = true;
      TranslateEnabled = true;
    };
  };
}
