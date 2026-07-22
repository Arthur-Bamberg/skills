---
name: feature-loop
description: Pipeline completo de feature — grill-with-docs (sempre seguindo a recomendação), confirmação de decisões, TDD unitário, implementação, revisão, testes locais, e2e e guia do caminho feliz. Use quando o usuário pedir feature-loop, /feature-loop, ou um fluxo grill→TDD→review→e2e.
disable-model-invocation: true
---

# Feature Loop

Pipeline sequencial para entregar uma feature com decisões documentadas, TDD e verificação ponta a ponta.

Skills relacionadas (ler e seguir quando a fase exigir):

- `grill-with-docs` — `~/.agents/skills/grill-with-docs/SKILL.md`
- `tdd` — `~/.agents/skills/tdd/SKILL.md`
- `review` — `~/.agents/skills/review/SKILL.md`

## Regras transversais

### Sempre seguir a recomendação

No grill e em qualquer decisão de design: para cada pergunta, declare a **recomendação** e **aplique-a** a menos que o usuário override explicitamente. Não deixe a decisão em aberto entre opções equivalentes.

### Loop de correção (progresso vs stuck)

Ao encontrar um problema (review, unit, local, e2e ou outro):

1. Registre o bug (assinatura curta + fase).
2. Tente corrigir **uma vez**.
3. Reexecute a verificação que falhou.
4. **Mesma assinatura** após a correção → **pare**, reporte o bug, o que tentou e o estado atual. Não continue o pipeline.
5. **Assinatura diferente** (novo problema) → progresso: corrija o novo, continue o mesmo loop.
6. Só avance de fase quando a verificação atual estiver verde (ou o usuário autorizar seguir com débito explícito).

Assinatura = mensagem/erro estável + arquivo/teste/check que falhou (não o número da linha sozinho).

### Diário de bugs

Mantenha um diário durante toda a sessão. No fim (ou na parada), entregue a tabela:

```markdown
| # | Bug | Fase | Status | Notas |
|---|-----|------|--------|-------|
| 1 | … | unit / e2e / review / local / outro | resolvido / bloqueado | … |
```

Fases válidas: `grill`, `unit`, `impl`, `review`, `local`, `e2e`, `outro` (nomear o outro).

---

## Fase 0 — Escopo

Confirme em uma frase o que será construído e em qual repo/pasta. Se o workspace não for o projeto certo, mova o agent para a raiz do projeto antes de editar código.

---

## Fase 1 — Grill (com docs)

Siga `grill-with-docs` na íntegra, com estes overrides:

1. Uma pergunta por vez; espere feedback.
2. Em **toda** pergunta: proponha a recomendação e, salvo override do usuário, **trate a recomendação como decisão**.
3. Explore o codebase quando a resposta estiver lá.
4. Atualize `CONTEXT.md` / ADRs conforme a skill (lazy, só quando houver o que escrever).

Não pule para TDD enquanto houver ramo aberto no design tree.

---

## Fase 2 — Confirmação de decisões

Antes de qualquer teste ou implementação, apresente um resumo curto e peça confirmação explícita:

```markdown
## Perguntas e decisões

| # | Pergunta | Decisão (recomendação aplicada / override) |
|---|----------|-----------------------------------------------|
| 1 | … | … |

## Escopo da implementação
- Comportamentos a cobrir (unit): …
- Fora de escopo: …
```

**Pare aqui** até o usuário confirmar (ou ajustar). Só então vá para a Fase 3.

---

## Fase 3 — TDD unitário → implementação

Siga `tdd`:

1. Planeje comportamentos e interface pública; alinhe vocabulário com `CONTEXT.md` / ADRs.
2. **Vertical slices**: um teste → implementação mínima → próximo. Proibido escrever todos os testes e depois toda a impl.
3. RED → GREEN; refactor só em GREEN.
4. Testes de comportamento via interface pública (não detalhes internos).

Aplique o **loop de correção** se um teste ou implementação emperrar no mesmo erro.

---

## Fase 4 — Revisão de código

Revise o diff da feature (contra a base combinada com o usuário, default `main`):

- Eixos: **Standards** (convenções do repo) e **Spec** (decisões da Fase 2 + comportamentos acordados).
- Preferir a skill `review` quando houver ponto fixo e spec; senão, revisão direta equivalente.

Para cada achado acionável: corrija seguindo o **loop de correção**. Achados cosméticos opcionais: listar, não bloquear.

---

## Fase 5 — Testar tudo local

Na raiz do projeto, rode o que o repo já usa (detectar scripts/docs; não inventar stack):

- format / lint
- typecheck
- testes unitários / suite de CI local

Corrija falhas com o **loop de correção**. Só avance com suite local verde.

---

## Fase 6 — Testes e2e

1. Descubra a stack e2e do repo (Playwright, Cypress, etc.) e os padrões existentes.
2. Cubra o **caminho feliz** da feature acordada (e só edge cases críticos se já fizerem parte do escopo).
3. Escreva e rode os e2e; corrija com o **loop de correção**.

Se o projeto não tiver e2e: proponha o mínimo viável no padrão mais próximo do repo, confirme com o usuário, então implemente.

---

## Fase 7 — Caminho feliz manual

Explique o passo a passo para o usuário validar na mão:

```markdown
## Caminho feliz (manual)

Pré-requisitos: …

1. …
2. …
3. …

Resultado esperado: …
```

Seja concreto (URLs, comandos, dados de exemplo). Sem alternativa longa — um caminho feliz claro.

---

## Entrega final

Ao concluir (ou ao parar por erro repetido), entregue nesta ordem:

1. Status do pipeline (qual fase terminou / onde parou).
2. Tabela de bugs (diário).
3. Caminho feliz manual (se chegou na Fase 7).
4. Próximo passo sugerido só se bloqueado (ex.: decisão humana necessária).

Não faça commit/PR a menos que o usuário peça.
