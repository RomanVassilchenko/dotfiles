{
  dotfiles,
  lib,
  ...
}:
let
  gitUsername = dotfiles.user.gitName;
  gitEmail = dotfiles.user.gitEmail;
  githubUsername = dotfiles.user.githubName;
  githubEmail = dotfiles.user.githubEmail;
in
{
  home.file = lib.optionalAttrs (githubEmail != null) {
    ".config/git/github".text = ''
      [user]
        name = ${githubUsername}
        email = ${githubEmail}
    '';
  };

  programs.git = {
    enable = true;
    signing.format = null;
    includes = lib.mkAfter (
      lib.optionals (githubEmail != null) [
        {
          condition = "hasconfig:remote.*.url:git@github.com:*/**";
          path = "~/.config/git/github";
        }
        {
          condition = "hasconfig:remote.*.url:https://github.com/**";
          path = "~/.config/git/github";
        }
      ]
    );

    settings = {
      user = {
        name = gitUsername;
      }
      // lib.optionalAttrs (gitEmail != null) {
        email = gitEmail;
      };

      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;

      push.default = "simple";
      credential.helper = "cache --timeout=7200";
      init.defaultBranch = "main";
      log.decorate = "full";
      log.date = "iso";
      merge.conflictStyle = "diff3";

      url."git@github.com:".insteadOf = "https://github.com/";

      maintenance = {
        auto = true;
        strategy = "incremental";
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      branch.sort = "-committerdate";
      column.ui = "auto";

      fetch = {
        prune = true;
        pruneTags = true;
        parallel = 0;
      };

      pull.rebase = true;

      rebase = {
        autoStash = true;
        autoSquash = true;
      };

      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Catppuccin Mocha";
        features = "decorations";
        hyperlinks = true;
        keep-plus-minus-markers = true;
        hunk-header-style = "file line-number syntax";
        minus-style = "syntax #313244";
        minus-emph-style = "syntax bold #f38ba8";
        plus-style = "syntax #313244";
        plus-emph-style = "syntax bold #a6e3a1";
      };
      delta.decorations = {
        commit-decoration-style = "bold #cba6f7 box ul"; # mauve
        file-style = "bold #cba6f7 ul"; # mauve
        file-decoration-style = "none";
        hunk-header-decoration-style = "#89b4fa box"; # blue
      };
      diff.colorMoved = "default";

      alias = {
        # AI commit message and commit via opencode
        ai = "!git-ai-commit";

        # Undo operations
        undo = "reset --soft HEAD~1";
        unstage = "reset HEAD --";
        discard = "checkout --";
        nuke = "!git reset --hard HEAD && git clean -fd";

        # Quick commits
        fixup = "commit --fixup";
        wip = "commit -am 'WIP'";
        amend = "commit --amend --no-edit";

        # Info & inspection
        last = "log -1 HEAD --stat";
        graph = "log --graph --oneline --decorate --all";
        who = "shortlog -sn --no-merges";
        today = "log --since='midnight' --oneline --author";
        recent = "branch --sort=-committerdate --format='%(refname:short) (%(committerdate:relative))'";

        # Branch management
        branches = "branch -vv";
        gone = "!git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}'";
        cleanup = "!git gone | xargs -r git branch -D";
        default = "!git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'";
        sync = "!git fetch --all --prune && git rebase origin/$(git default)";

        # Diff helpers
        staged = "diff --staged";
        conflicts = "diff --name-only --diff-filter=U";
        changed = "diff --name-only";

        # Stash helpers
        stash-all = "stash push --include-untracked";
        snapshot = "!git stash push -m \"snapshot: $(date)\" && git stash apply";

        # Root of repo
        root = "rev-parse --show-toplevel";
        exec = "!exec ";

        # Meta
        aliases = "!git config --list | grep ^alias | sed 's/alias\\.//'";
      };
    };
  };
}
