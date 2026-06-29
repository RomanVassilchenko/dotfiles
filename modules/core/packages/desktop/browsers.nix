{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  crxUrl =
    id:
    "https://clients2.google.com/service/update2/crx?response=redirect"
    + "&prodversion=149.0.7827.53"
    + "&acceptformat=crx2,crx3"
    + "&x=id%3D${id}%26installsource%3Dondemand%26uc";

  heliumExtensions = {
    aapbdbdomjkkjkaonfhkkikfgjllcleb = {
      name = "Google Translate";
      version = "2.0.16";
      crx = pkgs.fetchurl {
        name = "aapbdbdomjkkjkaonfhkkikfgjllcleb.crx";
        url = crxUrl "aapbdbdomjkkjkaonfhkkikfgjllcleb";
        hash = "sha256-Z05TixCLsTuLjrm+e3T39tPMIu4buFw93Nm/lxpF3AI=";
      };
    };
    hkgfoiooedgoejojocmhlaklaeopbecg = {
      name = "Picture-in-Picture";
      version = "1.14";
      crx = pkgs.fetchurl {
        name = "hkgfoiooedgoejojocmhlaklaeopbecg.crx";
        url = crxUrl "hkgfoiooedgoejojocmhlaklaeopbecg";
        hash = "sha256-NaWNfAH9zyLIVpmK5+cb72PUZ3whU5NwCb+9BA45aGc=";
      };
    };
    kekjfbackdeiabghhcdklcdoekaanoel = {
      name = "MAL-Sync";
      version = "0.12.3";
      crx = pkgs.fetchurl {
        name = "kekjfbackdeiabghhcdklcdoekaanoel.crx";
        url = crxUrl "kekjfbackdeiabghhcdklcdoekaanoel";
        hash = "sha256-JNV97f+K6txBWrlkurFk4x8Yy2TFFC9RM396r0mORfQ=";
      };
    };
    mnjggcdmjocbbbhaepdhchncahnbgone = {
      name = "SponsorBlock";
      version = "6.1.6";
      crx = pkgs.fetchurl {
        name = "mnjggcdmjocbbbhaepdhchncahnbgone.crx";
        url = crxUrl "mnjggcdmjocbbbhaepdhchncahnbgone";
        hash = "sha256-VYf+K2qZRhAcoN3nxu/nanVcXuW21uY9/EjH9zbNtP8=";
      };
    };
    nffaoalbilbmmfgbnbgppjihopabppdk = {
      name = "Video Speed Controller";
      version = "0.10.2";
      crx = pkgs.fetchurl {
        name = "nffaoalbilbmmfgbnbgppjihopabppdk.crx";
        url = crxUrl "nffaoalbilbmmfgbnbgppjihopabppdk";
        hash = "sha256-bJUxLYTCx+UCbpxZW0+By4NfK2oiYxWbhy+766a0dUY=";
      };
    };
    nngceckbapebfimnlniiiahkandclblb = {
      name = "Bitwarden";
      version = "2026.6.0";
      crx = pkgs.fetchurl {
        name = "nngceckbapebfimnlniiiahkandclblb.crx";
        url = crxUrl "nngceckbapebfimnlniiiahkandclblb";
        hash = "sha256-szBs8uPHBpgx4VAprSLOtD1XOAjUgecoAp6aJsvuT74=";
      };
    };
  };

  heliumExtensionUpdateManifest = pkgs.writeText "helium-extension-updates.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <gupdate xmlns="http://www.google.com/update2/response" protocol="2.0">
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (id: extension: ''
        <app appid="${id}">
          <updatecheck codebase="file://${extension.crx}" version="${extension.version}" />
        </app>'') heliumExtensions
    )}
    </gupdate>
  '';
in
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
      ExtensionSettings =
        let
          systemInstall = {
            installation_mode = "force_installed";
            update_url = "file://${heliumExtensionUpdateManifest}";
          };
        in
        {
          aapbdbdomjkkjkaonfhkkikfgjllcleb = systemInstall; # Google Translate
          hkgfoiooedgoejojocmhlaklaeopbecg = systemInstall; # Picture-in-Picture
          kekjfbackdeiabghhcdklcdoekaanoel = systemInstall; # MAL-Sync
          mnjggcdmjocbbbhaepdhchncahnbgone = systemInstall; # SponsorBlock
          nffaoalbilbmmfgbnbgppjihopabppdk = systemInstall; # Video Speed Controller
          nngceckbapebfimnlniiiahkandclblb = systemInstall; # Bitwarden
        };
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
