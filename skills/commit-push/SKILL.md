---
name: commit-push
description: Atualiza a branch com rebase em main, roda format/typecheck/test, corrige falhas, faz commit conventional em pt-BR, force push, abre PR para main, entrega o link do workflow run do GitHub Actions e monitora CI/deploys até todos ficarem verdes (corrige falhas; para se o mesmo erro repetir). Use quando o usuário pedir commit-push, preparar branch para PR, ou sincronizar e publicar alterações antes de abrir PR.
---

# Commit Push

Fluxo completo para deixar a branch atual pronta para PR em `main`, com acompanhamento do GitHub Actions até CI e deploys ficarem verdes.

## Pré-requisitos

- Estar na **raiz do repositório** git.
- Branch atual **não** pode ser `main` nem `master`.
- `gh` autenticado (para link/PR/Actions).
- `nvm` disponível no shell (se existir `.nvmrc` no projeto).

## Fluxo

### 1. Estado inicial

```bash
git status
git branch --show-current
```

Se estiver em `main`/`master`, **pare** e avise o usuário — não force push nessas branches.

### 2. Atualizar `main` e rebase

```bash
git fetch origin main
git rebase origin/main
```

- Conflitos: resolver arquivos, `git add` nos resolvidos, `git rebase --continue`.
- Rebase abortado pelo usuário: não continuar para commit/push.

### 3. Node e qualidade

Carregar nvm e usar versão do projeto (se houver `.nvmrc`):

```bash
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -f .nvmrc ] && nvm use
```

Rodar em sequência (parar no primeiro erro):

```bash
npm run format
npm run typecheck
npm run test
```

- Se `npm run test` entrar em watch e não terminar, usar `npm run test:run` (ou `CI=true npm run test`).
- Falha em format/typecheck/test: **corrigir o código** e repetir os três comandos até passar.
- Não commitar `.env`, credenciais ou segredos.
- Se o projeto usar `pnpm` (ex.: monorepo com `pnpm-lock.yaml`), preferir `pnpm format` / `pnpm typecheck` / `pnpm test` (ou os scripts equivalentes do workspace).

### 4. Commit (Conventional Commits, pt-BR)

1. `git status` e `git diff` — entender o que será commitado.
2. Incluir apenas arquivos relevantes (`git add` seletivo).
3. Mensagem no padrão do repositório:

```
<tipo>(<escopo opcional>): <descrição imperativa em pt-BR>

[corpo opcional]
```

**Tipos:** `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `style`, `perf`, `build`, `ci`.

**Exemplos (estilo do time):**

```
feat(validacao-biometria): implementa fluxo de validação biométrica CD SIAPE
fix(proposta): corrige retomada quando guarda de fluxo está ativa
refactor(consumer): extrai mapeamento de status para handler dedicado
```

Commit via HEREDOC:

```bash
git commit -m "$(cat <<'EOF'
feat(escopo): descrição curta em pt-BR

EOF
)"
```

- Só commitar quando o usuário invocou esta skill (pedido explícito de commit/push).
- Hook falhou: corrigir e **novo** commit (não `--amend` salvo regras do projeto).
- Nada para commitar após format: se só houve mudanças de formatação já staged, commitar; se working tree limpa, pular commit.

### 5. Push

```bash
git push --force-with-lease origin HEAD
```

Usar `--force-with-lease` (não `--force` seco). **Nunca** force push em `main`/`master`.

### 6. Abrir PR para `main`

**PR já existe** — só entregar a URL:

```bash
gh pr view --json url -q .url
```

**Sem PR ainda** — criar pela CLI (preferido):

```bash
gh pr create --base main --head "$(git branch --show-current)" --fill
```

Se `gh pr create` falhar (auth, permissão, rede, etc.), **fallback** — link compare para abrir manualmente:

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
BRANCH=$(git branch --show-current)
echo "https://github.com/${REPO}/compare/main...${BRANCH}?expand=1"
```

### 7. Link do workflow run (GitHub Actions)

Assim que o push existir no remoto, **localizar o run criado para o HEAD atual** e entregar o **URL desse run** ao usuário (não só a listagem filtrada por branch).

```bash
SHA=$(git rev-parse HEAD)
# Aguardar o run aparecer (Actions pode demorar alguns segundos após o push)
gh run list --commit "$SHA" --json databaseId,url,status,conclusion,name,workflowName,createdAt --limit 20
```

- Preferir o(s) run(s) cujo `headSha`/`commit` seja o SHA recém-enviado.
- Entregar ao usuário o **link concreto** de cada run relevante (`url` do `gh run view` / `gh run list`).
- Se ainda não houver run: retry curto (ex.: a cada 5–10s, até ~1–2 min) até aparecer; se não aparecer, avisar e seguir monitorando via `gh pr checks`.

Exemplo para URL de um run específico:

```bash
gh run view <run-id> --json url,status,conclusion,name,workflowName -q .
```

### 8. Monitorar até CI e deploys ficarem verdes

**Não encerrar a skill** só com o link da PR. Ficar **monitorando na mesma sessão** até **todos** os checks anexados à PR (CI + deploys / multi-deploys) estarem verdes.

Fonte de verdade dos checks da PR:

```bash
gh pr checks --json name,bucket,state,workflow,link
```

Enquanto houver pendentes:

```bash
gh pr checks --watch --fail-fast
```

Após cada ciclo de watch (ou se já houver falha):

1. Reavaliar o conjunto completo com `gh pr checks --json ...` (o conjunto pode mudar após novo push).
2. **Sucesso:** só avisar “subiu de fato” quando **nenhum** check estiver pendente/falho — em multi-deploys, **todos** devem estar verdes.
3. **Falha:** seguir a seção 9 (corrigir e subir de novo).
4. Rodar de novo o watch após cada push corretivo.

Avisar o usuário:

- **Imediatamente após o push:** URL da PR + URL(s) do(s) workflow run(s) criado(s).
- **Ao final, quando tudo estiver verde:** confirmação explícita de que CI e deploys concluíram com sucesso (listar o que passou, se houver vários).

### 9. Falha de CI/deploy — corrigir e subir

Quando um check falhar:

1. Identificar o job/check que falhou (`gh pr checks` + `link`).
2. Se for GitHub Actions, ler o erro real:

```bash
gh run view <run-id> --log-failed
```

3. Aplicar o menor ajuste seguro no código.
4. Rodar de novo format/typecheck/test locais (seção 3) no que for aplicável.
5. Commit conventional + `git push --force-with-lease origin HEAD`.
6. Entregar o **novo** link do workflow run do SHA atual (seção 7).
7. Voltar a monitorar (seção 8).

#### Parada por erro repetido

Guardar uma assinatura do erro tratado em cada iteração (mensagem principal / step que falhou / trecho estável do log — não o timestamp).

- Se, após uma correção e novo push, o **mesmo erro** (mesma assinatura) voltar a falhar: **pare o loop**, reporte o erro, o que já tentou, e os links da PR/run. Não continue empurrando fixes cegos.
- Erro **diferente** após a correção: pode continuar o ciclo (corrigir o novo erro).
- Flake evidente (mesmo job falha sem causa no diff, ou passa no retry sem mudança): retry **uma** vez; se repetir igual, trate como erro repetido e pare.

Não usar `--no-verify` para forçar progresso. Se a falha for claramente alheia ao PR e já corrigida em `main`, rebase em `origin/main` em vez de inchá-lo com fixes não relacionados.

## Entrega ao usuário

Ao longo / ao final do fluxo:

- URL da PR (ou compare se a criação falhou).
- Branch, resumo do commit (hash + mensagem).
- Confirmação de que format/typecheck/test locais passaram.
- URL do(s) **workflow run(s)** criado(s) após o push (e após cada push corretivo).
- Quando aplicável: confirmação final de que **todos** os checks/deploys estão verdes, ou parada documentada por erro repetido.

## Checklist rápido

```
- [ ] Branch ≠ main/master
- [ ] git fetch + rebase origin/main OK
- [ ] nvm use (se .nvmrc)
- [ ] format + typecheck + test OK
- [ ] commit conventional pt-BR
- [ ] push --force-with-lease
- [ ] gh pr create (fallback: link compare) para main
- [ ] link do workflow run do SHA enviado entregue ao usuário
- [ ] monitoramento até todos CI + deploys verdes
- [ ] em falha: ler logs → corrigir → push → novo link de run
- [ ] parar se o mesmo erro repetir após correção
```

## Segurança

- Não alterar `git config`.
- Não usar `--no-verify` salvo pedido explícito.
- Não commitar segredos.
- Não force push em `main`/`master`.
