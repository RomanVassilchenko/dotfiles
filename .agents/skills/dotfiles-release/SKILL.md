---
name: dotfiles-release
description: Commit and push this dotfiles repo private-first, then public, then rebuild. Use only inside this repository.
---

**Все сообщения пользователю на русском языке.**

## Назначение

Этот repo-local skill выполняет release workflow только для `/home/romanv/Documents/dotfiles`:

1. Проверить состояние private submodule.
2. Закоммитить все изменения в private repo, если они есть.
3. Запушить private repo.
4. Закоммитить все изменения в public repo, если они есть.
5. Запушить public repo.
6. Выполнить rebuild.

## Важные правила

- Не выполнять workflow молча. Skill запускается только когда пользователь явно просит release/commit/push/rebuild dotfiles.
- Работать только с `/home/romanv/Documents/dotfiles` и `/home/romanv/Documents/dotfiles/private`.
- Коммитить все изменения, включая удаления и untracked файлы, кроме явно ignored файлов.
- Не добавлять ignored файлы через `git add -f`.
- Не раскрывать содержимое private файлов в ответах, diff snippets или commit message.
- Не читать содержимое секретов, ключей, `.env`, raw private config и auth/session файлов.
- Перед commit проверить `git status --short --ignored=matching` отдельно в private и public.
- Если видишь подозрительный untracked private material в public repo, остановиться и исправить `.gitignore` или спросить пользователя.
- Если private repo не содержит изменений, не создавать empty commit, а переходить к public.
- Если public repo не содержит изменений, не создавать empty commit, а переходить к rebuild.
- Не использовать `--no-verify`, `--force`, `push --force`, `commit --amend`.
- Commit messages писать без упоминания AI.

## Проверка перед commit

Выполнить в private repo:

```bash
git status --short --ignored=matching
git diff --stat
git diff --cached --stat
```

Выполнить в public repo:

```bash
git status --short --ignored=matching
git diff --stat
git diff --cached --stat
```

Проверить, что public repo не tracking private-sensitive paths:

```bash
git grep -n -E 'id_personal|id_xiaoxinpro_work|config/ssh|\.config/git/secrets|\.codex/rules|obsidian/obsidian\.json|private/home/config' -- ':!private'
```

Если grep что-то нашел, не коммитить public до исправления.

## Private Commit

Рабочая директория: `/home/romanv/Documents/dotfiles/private`.

1. Выполнить `git status --short`.
2. Если есть изменения, выполнить `git add -A`.
3. Составить Conventional Commit message по изменениям.
4. Выполнить `git commit -m "<message>"`.
5. Выполнить `git push`.

Рекомендуемый тип commit:

- `chore: update private dotfiles state` для смешанных private changes.
- `fix: ...` только если это явное исправление поведения.
- `feat: ...` только если добавляется новая private-функциональность.

## Public Commit

Рабочая директория: `/home/romanv/Documents/dotfiles`.

1. Выполнить `git status --short`.
2. Если есть изменения, выполнить `git add -A`.
3. Убедиться, что submodule pointer `private` тоже попал в commit, если private был запушен.
4. Составить Conventional Commit message по изменениям.
5. Выполнить `git commit -m "<message>"`.
6. Выполнить `git push`.

Рекомендуемый тип commit:

- `chore: update dotfiles release` для смешанных Nix/config changes.
- `feat: add ...` для новых пакетов, modules или skills.
- `refactor: ...` для структурных изменений без нового поведения.
- `fix: ...` для исправлений конфигурации.

## Rebuild

После успешного push public repo выполнить:

```bash
dot rebuild --plain
```

Если rebuild упал:

1. Диагностировать ошибку.
2. Исправить минимально необходимым изменением.
3. Повторить private/public commit workflow только для новых изменений.
4. Повторить `dot rebuild --plain`.

## Финальный ответ

В конце коротко сообщить:

- private commit hash или что изменений не было;
- public commit hash или что изменений не было;
- push result;
- rebuild result.

Не включать содержимое private файлов.
