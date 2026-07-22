# cursor-skills

Backup privado das **configs pessoais** do Cursor: skills, custom agents e hooks.

Só entra o que é seu. Skills de terceiros (Matt Pocock, caveman, find-skills, etc.) podem continuar em `~/.agents/skills`, mas **não** são versionadas aqui.

Branch padrão: **main** (sem `master`).

## Estrutura

| Pasta / arquivo | Origem local | Uso |
|-----------------|--------------|-----|
| `cursor-skills/` | `~/.cursor/skills/` | Skills pessoais do Cursor |
| `cursor-agents/` | `~/.cursor/agents/` | Custom agents do Cursor |
| `agents-skills/` | `~/.agents/skills/<nome>` | Só agents skills listadas em `owned-agents-skills.txt` |
| `owned-agents-skills.txt` | — | Whitelist das agents skills pessoais |
| `cursor-user-rules.md` | Settings → Rules → User Rules | Backup manual das User Rules (sem sync automático) |
| `cursor-hooks/hooks.json` | `~/.cursor/hooks.json` | Config dos hooks de usuário |
| `cursor-hooks/hooks/` | `~/.cursor/hooks/` | Scripts dos hooks |

### Cursor skills (pessoais)

Tudo em `~/.cursor/skills/` é sincronizado.

### Custom agents (pessoais)

Tudo em `~/.cursor/agents/` é sincronizado (`code-reviewer`, `plano-de-testes`, …).

### Agents skills (pessoais)

Só as linhas de `owned-agents-skills.txt` entram no repo. Para versionar uma skill nova em `~/.agents/skills/`:

1. Adicione o nome da pasta em `owned-agents-skills.txt`
2. Rode o sync manual (ou edite a skill e espere o hook)

### User Rules (manuais)

As User Rules do Cursor **não** vivem em arquivo em `~/.cursor/` (ficam no Settings / cloud). O backup é `cursor-user-rules.md` — restore = colar no Settings. Sem sync automático: ao mudar a rule no Cursor, atualize o arquivo no repo.

## Restaurar em outra máquina

```bash
# Cursor skills (pessoais)
mkdir -p ~/.cursor/skills
cp -a cursor-skills/. ~/.cursor/skills/

# Custom agents
mkdir -p ~/.cursor/agents
cp -a cursor-agents/. ~/.cursor/agents/

# Agents skills (só as suas)
mkdir -p ~/.agents/skills
cp -a agents-skills/. ~/.agents/skills/

# Hooks
mkdir -p ~/.cursor/hooks
cp -a cursor-hooks/hooks.json ~/.cursor/hooks.json
cp -a cursor-hooks/hooks/. ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/*.sh

# User Rules (manual)
# Abra Cursor Settings → Rules → User Rules e cole o bloco de
# cursor-user-rules.md (ver instruções no próprio arquivo).
```

## Sync automático

Um hook de usuário (`~/.cursor/hooks.json` → `afterFileEdit`) sincroniza este repo quando o Agent edita:

- `~/.cursor/skills/` (qualquer skill pessoal)
- `~/.cursor/agents/` (qualquer custom agent)
- `~/.agents/skills/<owned>/` (só whitelist)
- `~/.cursor/hooks/`
- `~/.cursor/hooks.json`

Fluxo: debounce ~4s → `rsync`/`cp` → `git commit` → `git push`.

Scripts:

- `~/.cursor/hooks/sync-skills-on-edit.sh` — disparado pelo hook
- `~/.cursor/hooks/sync-skills-to-backup.sh` — sync manual / usado pelo hook

```bash
# sync manual (commit + push)
~/.cursor/hooks/sync-skills-to-backup.sh
```

Log: `${XDG_RUNTIME_DIR:-/tmp}/cursor-skills-sync/sync.log`

Se algo for criado só via shell (`mkdir`/`cp` sem Write/StrReplace), o hook não dispara — rode o sync manual.

Não versionar `~/.cursor/skills-cursor/` — essa pasta é gerenciada pelo Cursor.

Não versionar `~/.cursor/mcp.json` — costuma conter secrets.

User Rules não entram no sync automático — veja `cursor-user-rules.md`.
