# cursor-skills

Backup privado das configs **pessoais** do Cursor.

Só o que é seu. Skills de terceiros em `~/.agents/skills` podem ficar instaladas localmente, mas **não** entram neste repo.

Branch padrão: **main**.

## Conteúdo

| Path | Origem | Sync |
|------|--------|------|
| `cursor-skills/` | `~/.cursor/skills/` | automático |
| `cursor-agents/` | `~/.cursor/agents/` | automático |
| `agents-skills/` | `~/.agents/skills/<nome>` (whitelist) | automático |
| `owned-agents-skills.txt` | — | — |
| `cursor-hooks/` | `~/.cursor/hooks.json` + `~/.cursor/hooks/` | automático |
| `cursor-user-rules.md` | Settings → Rules → User Rules | **manual** |

### Inventário

**Skills** (`cursor-skills/`): `commit-push`, `envs`, `mvp-plan-doc`, `pr-dev`, `slack-grill-ship`

**Agents** (`cursor-agents/`): `code-reviewer`, `plano-de-testes`

**Agents skills** (`agents-skills/`, via whitelist): `feature-loop`

**User Rules**: backup em `cursor-user-rules.md` (colar no Settings para restaurar)

### Fora do backup

- `~/.cursor/skills-cursor/` — gerenciado pelo Cursor
- `~/.cursor/mcp.json` — secrets
- Skills de terceiros em `~/.agents/skills` — só entram nomes listados em `owned-agents-skills.txt`

## Restaurar

```bash
mkdir -p ~/.cursor/skills ~/.cursor/agents ~/.agents/skills ~/.cursor/hooks

cp -a cursor-skills/. ~/.cursor/skills/
cp -a cursor-agents/. ~/.cursor/agents/
cp -a agents-skills/. ~/.agents/skills/
cp -a cursor-hooks/hooks.json ~/.cursor/hooks.json
cp -a cursor-hooks/hooks/. ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/*.sh
```

User Rules: abra **Settings → Rules → User Rules** e cole o bloco de `cursor-user-rules.md`.

## Sync automático

Hook `afterFileEdit` em `~/.cursor/hooks.json`:

1. Detecta edição em skills / agents / hooks (agents skills só se estiverem na whitelist)
2. Debounce ~4s
3. `rsync` → `git commit` → `git push`

```bash
# sync manual
~/.cursor/hooks/sync-skills-to-backup.sh
```

Log: `${XDG_RUNTIME_DIR:-/tmp}/cursor-skills-sync/sync.log`

Criação só via shell (`mkdir`/`cp` sem Write/StrReplace) **não** dispara o hook — rode o sync manual.

### Nova agents skill pessoal

1. Crie em `~/.agents/skills/<nome>/`
2. Adicione `<nome>` em `owned-agents-skills.txt`
3. Rode o sync manual (ou edite a skill e espere o hook)

### User Rules

Sem sync automático. Ao mudar no Settings, atualize `cursor-user-rules.md` no repo.
