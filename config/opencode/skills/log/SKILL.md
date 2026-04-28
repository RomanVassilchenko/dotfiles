---
name: log
description: Log activity to Obsidian project folder. Call with "/log" or "log this".
---

**Все записи на русском языке.**

## Как работает

1. Определи проект из контекста сессии
2. Создай/обнови заметку: `YYYY-MM-DD.md` (временное имя)
3. Добавь запись о выполненной работе
4. Прочитай весь файл и сам придумай краткое описание (2-4 слова)
5. Переименуй файл: `mv "YYYY-MM-DD.md" "YYYY-MM-DD Описание.md"`
6. Закоммить **все** изменения в Obsidian vault, а не только новую daily заметку

## Определение проекта

**Приоритет 1 - Научные статьи и академическая работа:**

- Article, статья, paper, научная статья, research → **AITU** (даже если в контексте AdalQarau или других проектов)

**Приоритет 2 - Проекты:**

- OrqFlow → OrqFlow
- Dotfiles/NixOS → Personal
- Банк/Bereke B2C → Bereke B2C
- Банк/Bereke CoreHub → Bereke CoreHub
- DACA/AdalQarau → AdalQarau
- Учёба/AITU → AITU
- Ozon → Ozon

**Правило:** Если упоминается работа над статьей/article, всегда логировать в AITU, независимо от основного проекта.

## Путь к заметке

**ВСЕ** daily заметки (независимо от проекта) хранятся в одной папке:

```
~/Documents/Google\ Drive/Obsidian/Daily/YYYY-MM/YYYY-MM-DD Описание.md
```

Примеры:

- `~/Documents/Google\ Drive/Obsidian/Daily/2026-02/2026-02-05 Исправление UTF-8 ошибок.md`
- `~/Documents/Google\ Drive/Obsidian/Daily/2026-02/2026-02-05 Повышение покрытия тестами.md`
- `~/Documents/Google\ Drive/Obsidian/Daily/2026-02/2026-02-05 Написание статьи AdalQarau.md`
- `~/Documents/Google\ Drive/Obsidian/Daily/2026-02/2026-02-05 Настройка Obsidian Vault.md`

Если за один день несколько сессий — создаются **отдельные файлы** с разными описаниями (не добавлять в один файл чужой проект).

## Формат записи

```markdown
- Сделано: ПОДРОБНОЕ описание что было сделано. Не краткое, а детальное — что именно изменил, почему, какой результат.
- Файлы: список изменённых файлов
- Git: `ветка` `хэш` "commit message"
- #project #technology
```

**ВАЖНО:**

- Описание должно быть ПОДРОБНЫМ — что конкретно сделал, почему, какой эффект
- Если работа с git — ОБЯЗАТЕЛЬНО указать ветку, хэш коммита и сообщение
- Между записями ставить `---` разделитель

## Формат заметки

```markdown
---
date: YYYY-MM-DD
tags: [log]
---

# YYYY-MM-DD

- Сделано: ...
- Файлы: ...
- Git: `branch` `hash` "message"
- #project #technology

---

- Сделано: ...
```

Если заметка уже существует — добавь новую запись в конец с разделителем `---`.

## Генерация описания и переименование (ВАЖНО!)

**Claude сам придумывает название!**

После добавления записи:

1. **Прочитай весь файл** чтобы понять все записи за день
2. **Сам придумай краткое описание** (2-4 слова) основной темы работы
3. **Переименуй файл** в формат `YYYY-MM-DD Описание.md` используя bash mv

**Правила для описания:**

- 2-4 слова максимум
- На русском языке
- Отражает основную тему/результат работы
- Креативно и осмысленно описывает суть
- Без технических деталей (технологии в тегах, не в названии)

**Примеры хороших описаний:**

- "Исправление UTF-8 ошибок"
- "Повышение покрытия тестами"
- "Написание статьи"
- "Настройка Obsidian"
- "Рефакторинг архитектуры"
- "Интеграция с API"
- "Оптимизация производительности"
- "Миграция базы данных"

**Примеры плохих описаний:**

- ❌ "Работа над проектом" (слишком общее)
- ❌ "Исправил баг в sync_contracts и добавил тесты" (слишком длинно)
- ❌ "Go PostgreSQL" (технологии, не описание)
- ❌ "Разработка" (слишком абстрактно)

**Процесс:**

1. Создаешь/обновляешь файл с временным именем `YYYY-MM-DD.md`
2. Добавляешь запись
3. Читаешь весь файл
4. Придумываешь краткое описание
5. Переименовываешь файл: `mv "YYYY-MM-DD.md" "YYYY-MM-DD Описание.md"`

## Коммит Obsidian Vault

После создания/переименования daily заметки **обязательно** закоммить все текущие изменения в Obsidian vault.

**Важно:** коммитить нужно весь vault целиком, включая изменения, которые не связаны с последней daily заметкой. Не ограничивайся только созданным или изменённым `Daily/...` файлом.

Рабочая директория vault:

```bash
~/Documents/Google\ Drive/Obsidian
```

Процесс:

1. Выполни `git status --short` в корне vault.
2. Если изменений нет — не создавай empty commit.
3. Если изменения есть — выполни `git add -A` в корне vault.
4. Создай короткий Conventional Commit, обычно `docs: update daily notes` или более конкретный `docs: log dotfiles release`.
5. Выполни `git push`, если у текущей ветки настроен upstream.

Не читать и не выводить содержимое приватных заметок без необходимости. Для коммита достаточно `git status --short`, `git add -A`, `git commit` и `git push`.

## Разрешённые теги

**ВАЖНО: Все теги ТОЛЬКО на английском языке!**

### Проектные теги

- `#orqflow` `#adalqarau` `#bereke` `#b2c` `#corehub` `#ozon` `#aitu` `#personal`

### Типы контента

- `#log` - лог (автоматически добавляется в frontmatter)
- `#plan` `#task` `#note` `#reference` `#research`

### Технологии

- `#go` `#python` `#rust` `#java`
- `#vue` `#react` `#typescript` `#angular`
- `#postgresql` `#mongodb` `#neo4j` `#redis`
- `#docker` `#kubernetes` `#kafka` `#camunda`
- `#nixos` `#linux`
- `#testing` - тестирование

## Правила Obsidian Vault

**ВАЖНО:** Следуй правилам из `/home/romanv/Documents/Google\ Drive/Obsidian/CLAUDE.md`

- **НЕ** создавать YAML frontmatter в обычных документах (только в Daily)
- **НЕ** создавать локальные Resources в проектах (использовать общие `/Resources/`)
- Названия файлов: короткие, с пробелами
- Между записями в daily: разделитель `---`
- Создавать папки по месяцам: `Daily/YYYY-MM/`

## Пример

Файл: `~/Documents/Google\ Drive/Obsidian/Daily/2026-02/2026-02-05 Исправление UTF-8 ошибок.md`

```markdown
---
date: 2026-02-05
tags: [log]
---

# 2026-02-05

- Сделано: Исправил UTF-8 ошибку в синхронизации контрактов. Проблема: sync_contracts падал 13 дней на контракте 1028461 с ошибкой `invalid byte sequence for encoding "UTF8": 0x00`. Причина: GosZakup API возвращает null bytes. Решение: создал sanitize пакет для очистки строк с использованием strings.Map для фильтрации null bytes. Добавил тесты для проверки очистки строк с null bytes, unicode символами и emoji. Обновил contract_plan.go для использования sanitize при десериализации JSON.
- Файлы: internal/tools/sanitize/sanitize.go, internal/tools/sanitize/sanitize_test.go, internal/model/contract/contract_plan.go
- Git: `main` `00f449e` "fix: handle null bytes in contract plan sync from GosZakup API"
- #adalqarau #go #postgresql
```

Файл: `~/Documents/Google\ Drive/Obsidian/Daily/2026-02/2026-02-05 Настройка Obsidian Vault.md` (Personal/Dotfiles)

```markdown
---
date: 2026-02-05
tags: [log]
---

# 2026-02-05

- Сделано: Унифицировал структуру Obsidian vault...
- Файлы: config/.claude/skills/log/SKILL.md
- Git: `main` `abc1234` "chore: update obsidian log skill"
- #personal #nixos
```
