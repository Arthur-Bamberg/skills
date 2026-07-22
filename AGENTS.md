# AGENTS.md

Skills pessoais no padrão [agent-skills / OpenCode](https://opencode.ai/docs/skills/), espelhando a organização de [mattpocock/skills](https://github.com/mattpocock/skills).

## Layout

| Path | Papel |
|------|--------|
| `skills/<nome>/SKILL.md` | **Source of truth** das owned skills |
| `owned-skills.txt` | Whitelist das skills versionadas aqui |
| `scripts/link-skills.sh` | Symlink `skills/` → `~/.agents/skills`, `~/.config/opencode/skills`, `~/.cursor/skills` |
| `scripts/list-skills.sh` | Lista `SKILL.md` no repo |
| `.agents/` | Docs/ADRs **deste** repo (não skills) |
| `agents/` | **Side folder** — subagents Cursor (`~/.cursor/agents`) |
| `hooks/` | **Side folder** — hooks Cursor |
| `user-rules.md` | **Side folder** — backup manual de User Rules |
| `canvases/` | **Side folder** — canvases de referência |
| `CONTEXT.md` | Glossário do domínio deste repo |
| `README.md` | Inventário e quickstart |

## Regras

1. Edite skills **neste repo** (ou via symlink no harness — é o mesmo arquivo).
2. Depois de clonar ou adicionar skill: rode `scripts/link-skills.sh`.
3. Skills de terceiros **não** entram em `owned-skills.txt` / `skills/`.
4. Side folders não competem com `skills/` no README principal — ficam em seção própria.
5. Ao mudar inventário, atualize `README.md` (ver `.cursor/rules/keep-readme-updated.mdc`).

## Sync (Cursor)

`hooks/` sincroniza side folders e faz commit/push quando owned skills, agents ou hooks mudam. Skills já vivem no repo; o sync **não** sobrescreve `skills/` a partir de cópias locais soltas.
