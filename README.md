# skills

Skills pessoais no padrão [OpenCode / agent-skills](https://opencode.ai/docs/skills/), no espírito de [mattpocock/skills](https://github.com/mattpocock/skills): o **repo é a source of truth**; os harnesses consomem via symlink.

Branch padrão: **main**.

## Quickstart

```bash
git clone git@github.com:Arthur-Bamberg/skills.git ~/Projects/skills
cd ~/Projects/skills
chmod +x scripts/*.sh hooks/hooks/*.sh
./scripts/link-skills.sh
```

Opcional (Cursor side folders):

```bash
mkdir -p ~/.cursor/agents ~/.cursor/hooks
cp -a agents/. ~/.cursor/agents/
cp -a hooks/hooks.json ~/.cursor/hooks.json
cp -a hooks/hooks/. ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/*.sh
```

User rules: cole o bloco de `user-rules.md` em Cursor → Settings → Rules.

## Layout (padrão OpenCode)

| Path | Papel | Sync |
|------|--------|------|
| `skills/` | Source of truth das owned skills | link → harness |
| `owned-skills.txt` | Whitelist | — |
| `scripts/link-skills.sh` | Symlinks para harnesses | manual |
| `scripts/list-skills.sh` | Lista skills no repo | — |
| `.agents/` | ADRs/docs deste repo | — |
| `AGENTS.md` / `CONTEXT.md` | Orientações e glossário | — |
| `agents/` | Side folder — subagents Cursor | automático |
| `hooks/` | Side folder — hooks Cursor | automático |
| `user-rules.md` | Side folder — User Rules | **manual** |
| `canvases/` | Side folder — canvases de referência | **manual** |
| `.cursor/rules/` | Regras deste repo | — |

### Paths globais (harness)

| Escopo | Path |
|--------|------|
| agent-skills / OpenCode | `~/.agents/skills/<nome>/SKILL.md` |
| OpenCode nativo | `~/.config/opencode/skills/<nome>/SKILL.md` |
| Cursor | `~/.cursor/skills/<nome>/SKILL.md` |
| Projeto | `.agents/skills/`, `.opencode/skills/`, `.claude/skills/` |

`link-skills.sh` aponta os três paths globais acima para `skills/` neste repo.

## Inventário

**Skills** (`skills/`, via `owned-skills.txt`): `commit-push`, `envs`, `feature-loop`, `plan-feature-loop`, `mvp-plan-doc`, `pr-dev`, `reporte-excel`, `slack-grill-ship`

**Agents** (`agents/`): `code-reviewer`, `plano-de-testes`

**User rules** (`user-rules.md`): preferências de modelo (Composer 2.5 p/ implementação; evitar GPT-5.4 Nano como agente principal)

**Canvases** (`canvases/`): `composer-2-5-vs-gpt-5-4-nano.canvas.tsx`

**ADRs** (`.agents/adr/`): `0001-repo-is-skills-source-of-truth`

**Rules do repo** (`.cursor/rules/`): `keep-readme-updated`

### Fora do repo

- Skills de terceiros (não listadas em `owned-skills.txt`)
- Secrets (MCP, API keys, etc.)
- Skills internas da ferramenta (ex. `~/.cursor/skills-cursor/`)

## Nova skill pessoal

1. Crie `skills/<nome>/SKILL.md` neste repo
2. Adicione `<nome>` em `owned-skills.txt`
3. Rode `./scripts/link-skills.sh`
4. Commit e push

## Sync automático (Cursor)

Com hook `afterFileEdit` em `~/.cursor/hooks.json`:

1. Detecta edição em owned skill (repo ou symlink), agent ou hook
2. Debounce ~4s
3. Side folders → `git commit` → `git push` (`sync-skills-to-repo.sh`)

```bash
~/.cursor/hooks/sync-skills-to-repo.sh
```

Log: `${XDG_RUNTIME_DIR:-/tmp}/skills-sync/sync.log`

### Variáveis de ambiente

| Variável | Default | Uso |
|----------|---------|-----|
| `SKILLS_REPO` | `~/Projects/skills` | Este repo |
| `AGENTS_SKILLS_DIR` | `~/.agents/skills` | Harness agent-skills |
| `OPENCODE_SKILLS_DIR` | `~/.config/opencode/skills` | OpenCode nativo |
| `CURSOR_SKILLS_DIR` | `~/.cursor/skills` | Cursor |
| `AGENT_DEFINITIONS_DIR` | `~/.cursor/agents` | Subagents |
| `TOOL_HOOKS_DIR` | `~/.cursor/hooks` | Scripts de hook |
| `OWNED_SKILLS_LIST` | `$REPO/owned-skills.txt` | Whitelist |

Aliases legados ainda aceitos: `CURSOR_SKILLS_REPO`, `CURSOR_SKILLS_BACKUP_REPO`, `CURSOR_AGENTS_DIR`, `CURSOR_HOOKS_DIR`, `OWNED_AGENTS_SKILLS_LIST`.

## Referência

- [mattpocock/skills](https://github.com/mattpocock/skills) — layout, `link-skills.sh`, `AGENTS.md`, `CONTEXT.md`
- [OpenCode skills](https://opencode.ai/docs/skills/)
- ADR: [`.agents/adr/0001-repo-is-skills-source-of-truth.md`](./.agents/adr/0001-repo-is-skills-source-of-truth.md)
