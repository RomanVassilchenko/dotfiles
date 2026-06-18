# Release Flow

Use this flow when a change touches both the private submodule and the public
dotfiles repository.

1. Commit and push `private/` first.
2. Return to the public repository.
3. Stage the updated `private` gitlink in the parent repository.
4. Commit and push the public repository.
5. Log the release separately if needed.

`M private` in the parent repository means the submodule checkout is not at the
same commit recorded by the parent gitlink. That is expected after changing and
pushing `private/`; it is resolved only after staging and committing the gitlink
update in the public repository.

Run `dot check` before publishing when practical. Use `dot rebuild --dry` or
`dot rebuild --build` when the change affects NixOS modules, overlays, packages,
or system activation behavior.
