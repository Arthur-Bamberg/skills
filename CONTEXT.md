# Skills

Repositório pessoal de agent skills — fonte da verdade no padrão OpenCode / agent-skills (referência: [mattpocock/skills](https://github.com/mattpocock/skills)).

## Language

**Skill**:
Uma unidade de comportamento do agente (pasta com `SKILL.md`), instalável em harnesses compatíveis com o padrão agent-skills / OpenCode.
_Avoid_: command, prompt pack, cursor skill (como nome genérico)

**Repo**:
O repositório GitHub `Arthur-Bamberg/skills` (antes `cursor-skills`) — fonte da verdade das skills pessoais, não um espelho de uma IDE.
_Avoid_: cursor-skills, backup de Cursor

**Source of truth**:
O diretório `skills/` neste **Repo**. Harnesses consomem via symlink (`scripts/link-skills.sh`), não o contrário.
_Avoid_: backup, espelho, sync from home

**Side folder**:
Pasta auxiliar neste **Repo** que não é o produto principal: `agents/`, `hooks/`, `user-rules.md`, `canvases/`.
_Avoid_: skill bucket, promoted skill

**Owned skill**:
**Skill** pessoal listada em `owned-skills.txt` e versionada sob `skills/`. Skills de terceiros podem existir só no harness local.
_Avoid_: third-party skill, promoted skill

## Relationships

- O **Repo** contém muitas **Owned skills**
- **Source of truth** aponta para `skills/` no **Repo**
- **Side folders** convivem no **Repo** sem serem o centro do layout
