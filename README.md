# cursor-skills

Backup privado das skills globais do Cursor / agents.

## Estrutura

| Pasta | Origem local | Uso |
|-------|--------------|-----|
| `cursor-skills/` | `~/.cursor/skills/` | Skills pessoais do Cursor |
| `agents-skills/` | `~/.agents/skills/` | Skills instaladas em `~/.agents/skills` |

## Restaurar em outra máquina

```bash
# Cursor (pessoais)
cp -a cursor-skills/. ~/.cursor/skills/

# Agents
mkdir -p ~/.agents/skills
cp -a agents-skills/. ~/.agents/skills/
```

## Sync automático

Um hook de usuário (`~/.cursor/hooks.json` → `afterFileEdit`) sincroniza este repo sempre que o Agent edita arquivos em:

- `~/.cursor/skills/`
- `~/.agents/skills/`

Fluxo: debounce ~4s → `rsync` → `git commit` → `git push`.

Scripts:

- `~/.cursor/hooks/sync-skills-on-edit.sh` — disparado pelo hook
- `~/.cursor/hooks/sync-skills-to-backup.sh` — sync manual / usado pelo hook

```bash
# sync manual (commit + push)
~/.cursor/hooks/sync-skills-to-backup.sh
```

Log: `${XDG_RUNTIME_DIR:-/tmp}/cursor-skills-sync/sync.log`

Se a skill for criada só via shell (`mkdir`/`cp` sem Write/StrReplace), o hook não dispara — rode o sync manual.

Não versionar `~/.cursor/skills-cursor/` — essa pasta é gerenciada pelo Cursor.
