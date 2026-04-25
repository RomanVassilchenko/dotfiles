---
name: find-skills
description: Discover and install specialized agent skills from skills.sh when users need extended capabilities.
---

# Find Skills

Use this skill when the user asks to find, compare, install, or recommend an agent skill for a specific task or domain.

## Tools

Use the Skills CLI through `npx`:

```bash
npx skills find <query>
npx skills add <owner/repo> --skill <skill-name>
npx skills add <owner/repo@skill-name>
npx skills check
npx skills update
```

Browse manually at `https://skills.sh/`.

## Workflow

1. Clarify the domain and task if the request is vague.
2. Search with specific keywords, for example `npx skills find react performance`.
3. Prefer reputable sources and popular skills.
4. Verify quality before recommending: install count, source reputation, GitHub stars, and security audit status on `skills.sh`.
5. Present 2-4 options with install commands and links.
6. Install only when the user asks or clearly authorizes it.

## Recommended Install Pattern

For global user skills:

```bash
npx skills add <owner/repo> --skill <skill-name> -g -y
```

For this dotfiles setup, global OpenCode skills are managed under:

```text
~/.config/opencode/skills
```

Claude and Codex-compatible skill directories are symlinked to the same OpenCode skills directory.

## Quality Rules

- Prefer official or well-known publishers: `vercel-labs`, `anthropics`, `microsoft`, `supabase`, `shadcn`.
- Be cautious with low-install or unknown skills.
- Do not install skills that include suspicious scripts or unclear external calls without asking.
- Do not install private or secret-related skills into a public repository.

## Useful Examples

Find React skills:

```bash
npx skills find react
```

Install the `find-skills` skill from Vercel Labs:

```bash
npx skills add https://github.com/vercel-labs/skills --skill find-skills -g -y
```

Open the skill page:

```text
https://skills.sh/vercel-labs/skills/find-skills
```
