# cursor-skills

Backup privado de **skills e configs de agentes de IA** — compatível com [OpenCode](https://opencode.ai/docs/skills/), Cursor, Claude Code e outras ferramentas que leem o formato `SKILL.md`.

Só o que é seu. Skills de terceiros podem ficar instaladas localmente, mas **não** entram neste repo.

Branch padrão: **main**.

## Layout (padrão OpenCode / agent-skills)

| Path no repo | Origem global | Sync |
|--------------|---------------|------|
| `skills/` | `~/.agents/skills/<nome>` (whitelist) | automático |
| `owned-skills.txt` | — | — |
| `agents/` | definições de subagent (ex. `~/.cursor/agents/`) | automático |
| `hooks/` | hooks da ferramenta (ex. `~/.cursor/hooks.json` + scripts) | automático |
| `user-rules.md` | regras globais do assistente | **manual** |
| `canvases/` | canvases de referência (comparativos, etc.) | **manual** |
| `.cursor/rules/` | regras deste repo | — |

### Paths globais (OpenCode)

Ferramentas compatíveis carregam skills de:

| Escopo | Path |
|--------|------|
| Global (agent-skills) | `~/.agents/skills/<nome>/SKILL.md` |
| Global (OpenCode nativo) | `~/.config/opencode/skills/<nome>/SKILL.md` |
| Projeto | `.agents/skills/`, `.opencode/skills/`, `.claude/skills/` |

Este repo faz backup da whitelist em `~/.agents/skills` e **espelha** opcionalmente em `~/.config/opencode/skills` durante o sync.

### Inventário

**Skills** (`skills/`, via `owned-skills.txt`): `commit-push`, `envs`, `feature-loop`, `plan-feature-loop`, `mvp-plan-doc`, `pr-dev`, `reporte-excel`, `slack-grill-ship`

**Agents** (`agents/`): `code-reviewer`, `plano-de-testes`

**User rules** (`user-rules.md`): preferências de modelo do feature-loop (Composer 2.5 p/ implementação; evitar GPT-5.4 Nano como agente principal — restaurar manualmente na ferramenta)

**Canvases** (`canvases/`): `composer-2-5-vs-gpt-5-4-nano.canvas.tsx` (comparativo de benchmarks/preços)

**Rules do repo** (`.cursor/rules/`): `keep-readme-updated`

### Fora do backup

- Skills de terceiros — só entram nomes em `owned-skills.txt`
- Secrets (MCP, API keys, etc.)
- Skills internas gerenciadas pela ferramenta (ex. `~/.cursor/skills-cursor/` no Cursor)

## Restaurar

```bash
mkdir -p ~/.agents/skills ~/.config/opencode/skills ~/.cursor/agents ~/.cursor/hooks

cp -a skills/. ~/.agents/skills/
cp -a skills/. ~/.config/opencode/skills/   # opcional, OpenCode nativo
cp -a agents/. ~/.cursor/agents/              # se usar Cursor
cp -a hooks/hooks.json ~/.cursor/hooks.json   # se usar Cursor
cp -a hooks/hooks/. ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/*.sh
```

User rules: cole `user-rules.md` nas User Rules da sua ferramenta.

## Sync automático

Com **Cursor** e hook `afterFileEdit` em `~/.cursor/hooks.json`:

1. Detecta edição em skill owned, agent ou hook
2. Debounce ~4s
3. `rsync` → `git commit` → `git push`

```bash
~/.cursor/hooks/sync-skills-to-backup.sh
```

Log: `${XDG_RUNTIME_DIR:-/tmp}/cursor-skills-sync/sync.log`

Criação só via shell (`mkdir`/`cp`) **não** dispara o hook — rode o sync manual.

### Variáveis de ambiente

| Variável | Default | Uso |
|----------|---------|-----|
| `CURSOR_SKILLS_REPO` | `~/Projects/cursor-skills` | Este repo |
| `AGENTS_SKILLS_DIR` | `~/.agents/skills` | Skills globais (agent-skills) |
| `OPENCODE_SKILLS_DIR` | `~/.config/opencode/skills` | Espelho OpenCode (opcional) |
| `AGENT_DEFINITIONS_DIR` | `~/.cursor/agents` | Subagents (Cursor) |
| `TOOL_HOOKS_DIR` | `~/.cursor/hooks` | Scripts de hook |
| `OWNED_SKILLS_LIST` | `$REPO/owned-skills.txt` | Whitelist |

Aliases legados ainda aceitos: `CURSOR_SKILLS_BACKUP_REPO`, `CURSOR_AGENTS_DIR`, `CURSOR_HOOKS_DIR`, `OWNED_AGENTS_SKILLS_LIST`.

### Nova skill pessoal

1. Crie em `~/.agents/skills/<nome>/SKILL.md`
2. Adicione `<nome>` em `owned-skills.txt`
3. Rode o sync manual (ou edite e espere o hook no Cursor)

### User rules

Sem sync automático. Ao mudar na ferramenta, atualize `user-rules.md`.
