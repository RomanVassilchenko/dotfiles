# Feature Bundles

This repository has two feature layers:

- `features.*` is the host-facing API. Host files under `hosts/<name>/default.nix`
  should use this layer because it is compact and stable.
- `dotfiles.features.*` is the normalized internal configuration. System and
  Home Manager modules should read this layer because feature defaults and bundle
  expansion have already been applied.

For example, a host enables KDE through the public bundle:

```nix
{
  features.kde.enable = true;
}
```

The bundle maps that to internal options:

```nix
{
  dotfiles.features.desktop.enable = true;
  dotfiles.features.desktop.plasma.enable = true;
}
```

## Rules

- Put new host UX options under `features.*`.
- Put module-facing normalized options under `dotfiles.features.*`.
- Keep host files focused on bundles and explicit app overrides.
- Keep system and Home Manager modules from reading `features.*` directly.

## App Toggles

App overrides live under `features.apps.*` in host files and map to
`dotfiles.features.apps.*` internally. `null` in the public app layer means
"keep the bundle default".

```nix
{
  features = {
    productivity.enable = true;

    apps = {
      bitwarden.autostart = true;
      telegram.enable = false;
    };
  };
}
```

## Auto Imports

Module directories use automatic imports for sibling `.nix` files whose names do
not start with `_`. Use a leading underscore for disabled drafts, notes, or files
that are imported manually as data rather than as modules.
