# OpenCode Context Strategy

Keep always-loaded instructions small. Put domain-specific workflows in skills and load them only when the task matches.

## Context Hygiene

- Prefer short, durable facts over long explanations in persistent instructions.
- When context gets noisy or a task phase is complete, compress the closed part before continuing.
- A good compression handoff preserves: goal, changed files, decisions, current failure, verification already run, and the next exact step.
- Do not preserve style chatter, dead-end prompt drafts, or generic reasoning in compression summaries.

## Two-Correction Rule

- If the same issue needs two corrections and the fix is still wrong, stop iterating in the same context.
- Re-read the relevant files and restate the task with concrete acceptance criteria before editing again.
- If the context is polluted by failed approaches, clear or compress before the next implementation attempt.

## Verification First

- Give each non-trivial change a way to prove it works: a test, build, dry-run, lint, screenshot, or exact command.
- Prefer one targeted verification command before broader checks.
- Report verification results explicitly, including commands that could not be run.

## Skills

- Use `find-skills` when a missing domain workflow would otherwise make the base instructions longer.
