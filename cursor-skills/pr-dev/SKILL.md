---
name: pr-dev
description: Cria branch dev-<ticket> a partir de develop (sem alterar a branch atual), valida (format/typecheck/test), publica e abre PR com base develop. Use quando o usuário pedir pr-dev, branch dev para develop, PR para dev/develop, ou publicar alterações na integração de desenvolvimento.
---

# PR dev

Fluxo para publicar trabalho na branch de integração **`develop`** (time costuma chamar de **dev**). Não usar `main` neste fluxo salvo pedido explícito.

**Regra central:** sempre criar uma **nova** branch `dev-<ticket>` a partir de `develop`. **Nunca** fazer rebase, commit nem push na branch em que o usuário já estava trabalhando (ex.: `feat/BAN-XXX/...`).

## Pré-requisitos

- Raiz do repositório git.
- `gh` autenticado.
- `nvm` no shell se existir `.nvmrc`.
- Branch de destino (`dev-<ticket>`) **não** pode ser `develop`, `main` nem `master`.

## Nome da branch de destino

Padrão obrigatório: **`dev-<ticket>`** (ex.: `dev-BAN-592`).

- Extrair o ticket do nome da branch atual (ex.: `feat/BAN-592/cnpj` → `BAN-592`) ou do pedido do usuário.
- Se o usuário informar outro sufixo, usar `dev-<sufixo>` mantendo o prefixo `dev-`.
- Se `dev-<ticket>` já existir local ou no remoto: perguntar se deve usar sufixo (`dev-BAN-592-2`) ou reutilizar a existente; **não** sobrescrever a branch de feature original.

## Fluxo

### 1. Estado inicial

```bash
git status
git branch --show-current
```

Guardar a branch de origem (não será alterada pelo fluxo):

```bash
ORIGEM="$(git branch --show-current)"
```

- Identificar `<ticket>` a partir de `ORIGEM` ou perguntar ao usuário.
- Definir `DESTINO="dev-<ticket>"`.
- Se `ORIGEM` for `develop`, `main` ou `master`: ok — o trabalho será levado só para `DESTINO`.
- Alterações não commitadas: serão levadas via `stash` no passo 2 (a branch `ORIGEM` permanece intacta após o fluxo).

### 2. Criar `dev-<ticket>` a partir de develop (sem tocar em `ORIGEM`)

```bash
git fetch origin develop

# Trabalho não commitado (opcional, só se working tree suja)
git stash push -u -m "pr-dev: ${ORIGEM}"

# Nova branch a partir de develop atualizada — ORIGEM não é checkout permanente para edição
git checkout -b "${DESTINO}" origin/develop

# Commits da branch de origem que ainda não estão em develop
git cherry-pick origin/develop.."${ORIGEM}"

# Restaurar alterações não commitadas, se houve stash
git stash pop
```

- **Não** executar `git rebase` em `ORIGEM`.
- **Não** fazer `git checkout` de volta para `ORIGEM` para commitar ou publicar; todo commit/push/PR usa `DESTINO`.
- Conflitos no `cherry-pick` ou no `stash pop`: resolver em `DESTINO`, `git add`, `git cherry-pick --continue` (ou `git stash drop` se stash vazio). Se o usuário abortar, parar o fluxo; `ORIGEM` continua como estava antes do stash (recuperar com `git stash pop` na `ORIGEM` se necessário).
- Se não houver commits entre `origin/develop` e `ORIGEM`, pular o `cherry-pick`.
- Se `cherry-pick` falhar por commits vazios ou já aplicados, avaliar `git cherry-pick --skip` ou portar diff manualmente; não alterar `ORIGEM`.

### 3. Node e qualidade

Executar **em `DESTINO`**:

```bash
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm use && npm run format && npm run typecheck && npm run test
```

- Falha: corrigir em `DESTINO` e repetir até passar.
- Não commitar `.env`, credenciais ou segredos.

### 4. Commit (se houver mudanças em `DESTINO`)

1. `git status` e `git diff`.
2. `git add` seletivo nos arquivos relevantes.
3. Conventional Commits em **pt-BR**:

```
<tipo>(<escopo>): <descrição imperativa>

[corpo opcional]
```

Tipos: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `style`, `perf`, `build`, `ci`.

```bash
git commit -m "$(cat <<'EOF'
feat(escopo): descrição em pt-BR

EOF
)"
```

- Só commitar com pedido explícito do usuário ou ao invocar esta skill.
- Hook falhou: corrigir e **novo** commit (evitar `--amend` salvo regras do projeto).
- Working tree limpa após format: pular commit.

### 5. Push

Publicar **somente** `DESTINO`:

```bash
git push -u origin "${DESTINO}"
```

Se `DESTINO` já existia no remoto e foi recriada ou teve histórico reescrito em `DESTINO` (ex.: cherry-pick refeito):

```bash
git push --force-with-lease origin "${DESTINO}"
```

**Nunca** force push em `develop`, `main`, `master` nem na branch `ORIGEM`.

### 6. Pull request para develop

Em paralelo (estado de `DESTINO`):

```bash
git status
git diff
git log origin/develop..HEAD --oneline
```

**PR já aberta** para `develop` com head `DESTINO`:

```bash
gh pr view --json url,baseRefName,headRefName -q '"\(.url) (base: \(.baseRefName), head: \(.headRefName))"'
```

**Criar PR** (base `develop`, head `DESTINO`):

```bash
gh pr create --base develop --head "${DESTINO}" --title "<título>" --body "$(cat <<'EOF'
## Summary
- 

## Test plan
- [ ] 

EOF
)"
```

Preencher Summary e Test plan a partir do diff e dos commits (`origin/develop..HEAD`).

**Sem `gh pr create`:** link de compare:

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "https://github.com/${REPO}/compare/develop...${DESTINO}?expand=1"
```

Entregar ao usuário:

- URL da PR (ou compare)
- `ORIGEM` (inalterada) e `DESTINO` (publicada)
- base `develop`
- resumo dos commits e confirmação de format/typecheck/test

## Checklist

```
- [ ] Ticket identificado; DESTINO=dev-<ticket>
- [ ] ORIGEM preservada (sem rebase/commit/push nela)
- [ ] DESTINO criada a partir de origin/develop
- [ ] Commits/stash portados para DESTINO (cherry-pick/stash)
- [ ] nvm use + format + typecheck + test OK em DESTINO
- [ ] commit conventional pt-BR em DESTINO (se aplicável)
- [ ] push de DESTINO (-u ou --force-with-lease só em DESTINO)
- [ ] PR com base develop e head DESTINO
```

## Segurança

- Não alterar `git config`.
- Não usar `--no-verify` salvo pedido explícito.
- Não commitar segredos.
- Não force push em `develop`, `main`, `master` nem em `ORIGEM`.

## Relação com outras skills

- PR para **`main`**: skill pessoal `commit-push` (`~/.cursor/skills/commit-push/`).
- Este fluxo é exclusivo para integração em **`develop`** via branch **`dev-<ticket>`**.
