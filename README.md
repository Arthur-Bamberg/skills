# cursor-skills

Backup privado das skills e hooks globais do Cursor / agents.

## Estrutura

| Pasta / arquivo | Origem local | Uso |
|-----------------|--------------|-----|
| `cursor-skills/` | `~/.cursor/skills/` | Skills pessoais do Cursor |
| `agents-skills/` | `~/.agents/skills/` | Skills instaladas em `~/.agents/skills` |
| `cursor-hooks/hooks.json` | `~/.cursor/hooks.json` | Config dos hooks de usuário |
| `cursor-hooks/hooks/` | `~/.cursor/hooks/` | Scripts dos hooks |

## Restaurar em outra máquina

```bash
# Cursor (pessoais)
mkdir -p ~/.cursor/skills
cp -a cursor-skills/. ~/.cursor/skills/

# Agents
mkdir -p ~/.agents/skills
cp -a agents-skills/. ~/.agents/skills/

# Hooks
mkdir -p ~/.cursor/hooks
cp -a cursor-hooks/hooks.json ~/.cursor/hooks.json
cp -a cursor-hooks/hooks/. ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/*.sh
```

## Sync automático

Um hook de usuário (`~/.cursor/hooks.json` → `afterFileEdit`) sincroniza este repo sempre que o Agent edita arquivos em:

- `~/.cursor/skills/`
- `~/.agents/skills/`
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
