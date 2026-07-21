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

## Atualizar este backup a partir da máquina local

```bash
rsync -a --delete ~/.cursor/skills/ ./cursor-skills/
rsync -a --delete ~/.agents/skills/ ./agents-skills/
```

Não versionar `~/.cursor/skills-cursor/` — essa pasta é gerenciada pelo Cursor.
