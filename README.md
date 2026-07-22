# cursor-skills

Backup privado das **skills e hooks pessoais** do Cursor / agents.

Só entra o que é seu. Skills de terceiros (Matt Pocock, caveman, find-skills, etc.) podem continuar em `~/.agents/skills`, mas **não** são versionadas aqui.

## Estrutura

| Pasta / arquivo | Origem local | Uso |
|-----------------|--------------|-----|
| `cursor-skills/` | `~/.cursor/skills/` | Skills pessoais do Cursor |
| `agents-skills/` | `~/.agents/skills/<nome>` | Só agents skills listadas em `owned-agents-skills.txt` |
| `owned-agents-skills.txt` | — | Whitelist das agents skills pessoais |
| `cursor-hooks/hooks.json` | `~/.cursor/hooks.json` | Config dos hooks de usuário |
| `cursor-hooks/hooks/` | `~/.cursor/hooks/` | Scripts dos hooks |

### Cursor skills (pessoais)

Tudo em `~/.cursor/skills/` é sincronizado.

### Agents skills (pessoais)

Só as linhas de `owned-agents-skills.txt` entram no repo. Para versionar uma skill nova em `~/.agents/skills/`:

1. Adicione o nome da pasta em `owned-agents-skills.txt`
2. Rode o sync manual (ou edite a skill e espere o hook)

## Restaurar em outra máquina

```bash
# Cursor (pessoais)
mkdir -p ~/.cursor/skills
cp -a cursor-skills/. ~/.cursor/skills/

# Agents (só as suas)
mkdir -p ~/.agents/skills
cp -a agents-skills/. ~/.agents/skills/

# Hooks
mkdir -p ~/.cursor/hooks
cp -a cursor-hooks/hooks.json ~/.cursor/hooks.json
cp -a cursor-hooks/hooks/. ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/*.sh
```

## Sync automático

Um hook de usuário (`~/.cursor/hooks.json` → `afterFileEdit`) sincroniza este repo quando o Agent edita:

- `~/.cursor/skills/` (qualquer skill pessoal)
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
