# ADR 0001: Repo como source of truth das skills

## Status

Accepted — 2026-07-22

## Context

O repositório nasceu como `cursor-skills`, um **backup** que puxava skills de `~/.agents/skills` para o Git. Isso invertia o padrão OpenCode / [mattpocock/skills](https://github.com/mattpocock/skills), onde o repo é a fonte e o harness só consome (via symlink).

Também havia branding amarrado ao Cursor (`cursor-skills`, `CURSOR_SKILLS_*`), embora o conteúdo já fosse multi-harness.

## Decision

1. Renomear o repo para `Arthur-Bamberg/skills` (path local `~/Projects/skills`).
2. Tratar `skills/` no repo como **source of truth**.
3. Instalar nos harnesses com `scripts/link-skills.sh` (symlinks), no espírito do mattpocock.
4. Manter `agents/`, `hooks/`, `user-rules.md` e `canvases/` como **side folders** no mesmo repo.
5. Env principal: `SKILLS_REPO` (aliases legados `CURSOR_SKILLS_*` ainda aceitos).

## Consequences

- Editar uma skill no harness (path linkado) edita o repo diretamente.
- `sync-skills-to-repo.sh` deixa de fazer rsync de skills home→repo; só versiona o que já está no repo + side folders.
- Clones novos precisam rodar `link-skills.sh` após o restore.
- Nome e docs deixam de sugerir “backup de Cursor”.
