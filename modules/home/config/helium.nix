{
  config,
  dotfiles,
  lib,
  pkgs,
  ...
}:
let
  heliumPreferences = {
    bookmark_bar.show_on_all_tabs = false;
    browser.enable_spellchecking = true;
    helium.browser = {
      centered_location_bar = true;
      layout = 2;
      minimal_location_bar = true;
      show_avatar_button = false;
      show_back_button = true;
      show_dynamic_new_tab_button = false;
      show_media_button = false;
      show_menu_button = true;
      show_vertical_tabs_collapse_button = false;
      vertical_right_aligned = true;
      zen_mode = true;
      zen_mode_sidebar_pinned = false;
      zen_mode_top_chrome_pinned = false;
    };
    intl = {
      accept_languages = "en,ru";
      selected_languages = "en,ru";
    };
    ntp = {
      shortcust_visible = false;
      shortcuts_auto_removal_disabled = true;
    };
    privacy_sandbox = {
      first_party_sets_enabled = false;
      m1 = {
        ad_measurement_enabled = false;
        fledge_enabled = false;
        topics_enabled = false;
      };
    };
    session.restore_on_startup = 1;
    spellcheck = {
      dictionaries = [
        "en"
        "ru"
      ];
      dictionary = "";
      use_spelling_service = false;
    };
    vertical_tabs = {
      collapsed_state = false;
      uncollapsed_width = 200;
    };
  };

  heliumLocalState = {
    browser.enabled_labs_experiments = [
      "enable-gpu-rasterization@1"
      "enable-parallel-downloading@1"
      "enable-quic@1"
      "enable-zero-copy@1"
      "hide-tab-close-buttons"
      "smooth-scrolling@1"
    ];
  };

  preferencesFile = pkgs.writeText "helium-preferences.json" (builtins.toJSON heliumPreferences);
  localStateFile = pkgs.writeText "helium-local-state.json" (builtins.toJSON heliumLocalState);
in
lib.mkIf dotfiles.features.desktop.enable {
  home.activation.configureHeliumPreferences = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    prefs="${config.xdg.configHome}/net.imput.helium/Default/Preferences"
    local_state="${config.xdg.configHome}/net.imput.helium/Local State"

    if ${pkgs.procps}/bin/pgrep -u "$USER" -x helium >/dev/null; then
      echo "Skipping Helium profile configuration because Helium is running"
    else
      ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$prefs")"
      if [ ! -s "$prefs" ]; then
        ${pkgs.coreutils}/bin/printf '{}\n' > "$prefs"
      fi

      tmp="$(${pkgs.coreutils}/bin/mktemp)"
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$prefs" "${preferencesFile}" > "$tmp"
      ${pkgs.coreutils}/bin/install -m 600 "$tmp" "$prefs"
      ${pkgs.coreutils}/bin/rm -f "$tmp"

      if [ ! -s "$local_state" ]; then
        ${pkgs.coreutils}/bin/printf '{}\n' > "$local_state"
      fi

      tmp="$(${pkgs.coreutils}/bin/mktemp)"
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$local_state" "${localStateFile}" > "$tmp"
      ${pkgs.coreutils}/bin/install -m 600 "$tmp" "$local_state"
      ${pkgs.coreutils}/bin/rm -f "$tmp"
    fi
  '';
}
