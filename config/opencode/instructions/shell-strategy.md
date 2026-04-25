# Shell Non-Interactive Strategy

OpenCode shell execution is non-interactive. There is no TTY, so any command that waits for input, opens an editor, opens a pager, or asks for confirmation can hang until timeout.

## Rules

- Assume `CI=true` and a headless environment.
- Prefer built-in file tools over shell editing commands.
- Use explicit non-interactive flags: `-y`, `--yes`, `--force`, `--no-edit`, `--non-interactive`.
- Avoid editors and pagers: `vim`, `vi`, `nano`, `emacs`, `less`, `more`, `man`.
- Avoid interactive git: `git add -p`, `git rebase -i`, `git commit` without `-m`.
- Avoid REPLs: `python`, `node`, `irb`, `ghci` without `-c`, `-e`, or a script.
- For commands that might prompt, use a timeout or explicit input pipe.

## Command Patterns

Use these forms:

```bash
npm init -y
git commit -m "message"
git merge --no-edit branch
git --no-pager diff
docker compose up -d
python -c 'print("ok")'
node -e 'console.log("ok")'
timeout 30 ./script-that-might-hang.sh
```

Avoid these forms:

```bash
npm init
git commit
git add -p
git rebase -i
git log
docker run -it image
python
node
```

## Environment Defaults

When applicable, prefer these environment values:

```bash
CI=true
GIT_TERMINAL_PROMPT=0
GIT_EDITOR=true
GIT_PAGER=cat
PAGER=cat
PIP_NO_INPUT=1
npm_config_yes=true
```
