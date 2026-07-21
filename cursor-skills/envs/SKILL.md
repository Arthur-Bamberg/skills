---
name: envs
description: Detecta variáveis de ambiente novas na branch atual, mapeia em quais apps devem ser configuradas e entrega tabela com app, nome e valor sugerido. Use quando o usuário pedir envs, /envs, variáveis de ambiente novas, checklist de env para PR ou deploy, ou quais envs configurar na branch.
---

# Envs

Relatório read-only das envs **novas** introduzidas na branch atual. Não altera arquivos.

## Pré-requisitos

- Diretório dentro de um repositório git.
- `git` disponível. `gh` opcional (melhora detecção da branch base quando há PR aberto).

## Fluxo

### 1. Raiz do repositório

Subir até a raiz git, de qualquer subpasta:

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"
```

### 2. Branch base (fallback automático)

Resolver `BASE` nesta ordem; parar no primeiro que existir:

1. `gh pr view --json baseRefName -q .baseRefName` (PR aberto)
2. Nome da branch upstream: `git rev-parse --abbrev-ref @{upstream}` → parte após `/`
3. `main` se `git rev-parse --verify origin/main`
4. `master` se `git rev-parse --verify origin/master`
5. `develop` se `git rev-parse --verify origin/develop`

Antes do diff, atualizar refs remotas:

```bash
git fetch origin "$BASE" 2>/dev/null || true
```

Usar `origin/$BASE` como referência de comparação. Se não existir, usar `$BASE` local.

### 3. Arquivos relevantes no diff

```bash
git diff --name-only "origin/$BASE"...HEAD
```

Filtrar apenas arquivos que podem introduzir envs. **Ignorar** testes: `*.test.*`, `*.spec.*`, `__tests__/`, `__mocks__/`, `fixtures/`.

| Padrão | Fonte |
| --- | --- |
| `**/env.ts`, `**/env.js` | Schema Zod tipado |
| `**/.env.example`, `**/.env.sample`, `**/.env.template` | Envs documentadas |
| `*.{ts,tsx,js,jsx,mjs,cjs}` | `process.env.*`, `import.meta.env.*` |
| `*.{py}` | `os.environ`, `os.getenv` |
| `*.{php}` | `$_ENV`, `env(` |

### 4. O que é env nova

Incluir **somente chaves que não existiam** na base (`origin/$BASE`).

| Situação | Incluir? |
| --- | --- |
| Chave adicionada ao schema ou `.env.example` | Sim |
| Chave renomeada (`OLD` removida, `NEW` adicionada) | Sim (`NEW`) |
| Validação alterada, valor de exemplo alterado | Não |
| Chave removida | Não |

Para cada arquivo alterado, comparar conteúdo HEAD vs base:

```bash
git show "origin/$BASE:path/to/file" 2>/dev/null
```

Extrair conjunto de chaves em cada versão; a diferença (HEAD − base) são as novas.

**Parsers por fonte:**

- **Zod (`env.ts`)** — chaves dentro de `z.object({ ... })` (regex: `^\s*([A-Z][A-Z0-9_]*)\s*:`)
- **`.env.example`** — linhas `KEY=valor` ou `KEY=` (ignorar comentários `#` e linhas vazias)
- **`process.env.KEY`** / **`import.meta.env.KEY`** — identificador após o ponto
- **`os.getenv("KEY")`** / **`os.environ["KEY"]`** / **`env("KEY")`** — string entre aspas

### 5. Chaves a ignorar

Nunca incluir variáveis de sistema/CI:

`NODE_ENV`, `CI`, `PATH`, `HOME`, `USER`, `TERM`, `SHELL`, `LANG`, `PWD`, `HOSTNAME`, `SHLVL`, `TMPDIR`, `XDG_*`, `npm_*`, `PNPM_*`, `NVM_*`, `VSCODE_*`, `CURSOR_*`

### 6. Detectar apps

Resolver apps nesta ordem:

1. **Workspaces** — `pnpm-workspace.yaml`, `package.json` (`workspaces`), `turbo.json`
2. **Pastas `apps/` e `packages/`** com código (`.ts`, `.js`, `.py`, `.php`, `package.json`)
3. **Diretórios com `.env.example` próprio** — cada um é um app
4. **Fallback** — nome da pasta raiz do repo (`basename "$REPO_ROOT"`)

**Mapear env → app:** usar o caminho do arquivo onde a chave foi introduzida no diff.

- `apps/api/src/...` → app `api`
- `apps/@background/workers/foo/...` → app `@background/workers/foo` ou `foo` (usar o segmento mais específico com `.env.example` ou `env.ts` no mesmo subtree)
- Arquivo na raiz → app raiz (nome do repo)

Se a mesma chave nova aparece em apps diferentes, **uma linha por app**.

Deduplicar dentro do mesmo app (mesma chave em `env.ts` e `.env.example` → uma linha).

### 7. Valor sugerido

Para cada `app | nome`, preencher `valor sugerido` nesta ordem:

1. **Default Zod** — `.default(valor)` no schema (ex.: `PORT` → `3001`)
2. **Valor no `.env.example` de HEAD** — para chaves recém-adicionadas
3. **Secret** — se o nome contém (case-insensitive) `SECRET`, `PASSWORD`, `PASSWD`, `TOKEN`, `PRIVATE`, `CREDENTIAL`, ou termina em `_KEY` / `_DSN` → `*(obter com o time)*`
4. **Heurística por tipo no schema** — `z.string().url()` → `https://`; `z.coerce.number()` → `0`; boolean → `false`
5. **Fallback** — string vazia

### 8. Saída

Tabela markdown **estrita** com 3 colunas — sem seções extras, sem colunas adicionais:

| app | nome | valor sugerido |
| --- | --- | --- |
| api | `BETA_ACCESS_API_KEYS` | `key-dev-1,key-dev-2` |
| webhook-arbi | `PAGBANK_API_KEY` | `*(obter com o time)*` |

- Ordenar por `app`, depois `nome`.
- Envolver nomes em backticks na coluna `nome`.
- Se não houver envs novas: `Nenhuma env nova detectada nesta branch (base: origin/<BASE>).`

## Restrições

- **Read-only** — não editar `.env`, `.env.example`, `env.ts` nem secrets managers.
- Não commitar nem expor valores de `.env` locais (só `.env.example` e defaults de schema).
- Não listar envs que já existiam na base, mesmo que o valor tenha mudado.

