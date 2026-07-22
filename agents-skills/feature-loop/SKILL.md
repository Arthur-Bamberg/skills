---
name: feature-loop
description: Pipeline completo de feature — decisões em lote (Grok 4.5 High), confirmação, TDD+impl (Composer 2.5), review (Grok 4.5 High), suite local, e2e sem LLM real e caminho feliz. Use quando o usuário pedir feature-loop, /feature-loop, ou o fluxo decisões→TDD→review→e2e.
disable-model-invocation: true
---

# Feature Loop

Pipeline sequencial para entregar uma **fatia vertical de MVP** (tracer bullet) com decisões documentadas, TDD e verificação ponta a ponta.

**Não** use o modo entrevista uma-a-uma do `grill-with-docs` / `grill-me`. Aqui o grill é em lote: pensar → listar em markdown → repensar o conjunto → confirmar.

Para **planejar o programa de MVPs** (várias fatias, custo Cursor, tempo Cloud Agent), use a skill `mvp-plan-doc` antes; este loop entrega **uma** fatia por vez.

Skills / refs (ler quando a fase exigir):

- Domínio / formatos: `~/.agents/skills/grill-with-docs/` (`CONTEXT-FORMAT.md`, `ADR-FORMAT.md`)
- `tdd` — `~/.agents/skills/tdd/SKILL.md`
- `review` — `~/.agents/skills/review/SKILL.md`
- Plano multi-fatia: `~/.cursor/skills/mvp-plan-doc/SKILL.md`

## Política de modelos (obrigatória)

O Cursor **não troca o modelo sozinho** via rule/skill. Em cada fase:

| Fase | Modelo preferido | Ação do agent |
|------|------------------|---------------|
| 0–2 Decisões + confirmação | **Grok 4.5 High** | Se a sessão não estiver nele, **peça ao usuário trocar** (ou lance subagent com esse modelo se o usuário autorizar) antes de escrever `decisions.md` |
| 3 Impl TDD | **Composer 2.5** | Pedir troca / subagent Composer antes de codar |
| 4 Review | **Grok 4.5 High** | Pedir troca de volta para Grok High |
| 5 Suite local | qualquer (comandos shell) | Sem burn de LLM além de correções |
| 6 E2E | **sem LLM real no runtime do teste** | Escrever e2e com Composer; testes usam stubs/fixtures; assert sem chamar API de modelo |
| 7 Manual | humano | Só instruções |

Prefira pool **First-party** (Composer / Grok). Não use modelos API caros salvo pedido explícito.

No início da Fase 0 e a cada troca de fase que mude o modelo, diga em 1 linha: `Modelo desta fase: <nome> — troque no picker se ainda não estiver.`

## Âncora (quando o trabalho for de acessibilidade / agente de desktop)

Respeite a User Rule: priorize o que amplia acesso para pessoa deficiente visual (voz/TTS, confirmação falada, ações irreversíveis só com confirm). Isso pode alterar recomendações em `decisions.md`.

## Regras transversais

### Sempre seguir a recomendação

Em cada decisão: declare opções, marque a **recomendação**, e **aplique-a** salvo override explícito do usuário. Não deixe decisão empatada entre opções.

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

Fases válidas: `decisions`, `unit`, `impl`, `review`, `local`, `e2e`, `outro` (nomear o outro).

---

## Fase 0 — Escopo

**Modelo:** Grok 4.5 High.

Confirme em uma frase o que será construído e em qual repo/pasta. Se o workspace não for o projeto certo, mova o agent para a raiz do projeto antes de editar código.

Defina um slug curto da feature (ex.: `abrir-e-confirmar`) para os markdowns.

Se existir doc de MVPs (Notion / `mvp-plan-doc`), alinhe a fatia ao ID (MVP-A, MVP-B…). Não misture várias fatias num único loop.

Tipo: isto é **entrega de fatia**, não spike. Spike só se a fatia bloquear em incerteza técnica dura — time-box e volte ao loop.

---

## Fase 1 — Decisões em lote (pensar → anotar → repensar)

**Modelo:** Grok 4.5 High.

**Proibido:** perguntar uma decisão por vez e esperar resposta entre elas.

### 1.1 Explorar

Antes de decidir, explore o que já existe:

- Código relevante
- `CONTEXT.md` / `CONTEXT-MAP.md`
- `docs/adr/` (e ADRs por contexto, se houver)
- Doc de MVPs da feature, se houver

Se um fato estiver no código ou nos docs, use-o — não invente pergunta ociosa.

### 1.2 Pensar e anotar (passagem 1)

Percorra a árvore de design sozinho. Para cada ramo aberto, registre **uma entrada** no markdown de decisões.

Grave o arquivo (crie pastas se precisar):

`.scratch/feature-loop/<slug>/decisions.md`

Use este formato:

```markdown
# Decisões — <feature>

## Contexto
[1–3 frases do que será feito e o que já existe no domínio]

## Lista

### D1 — <título curto>
- **Pergunta:** …
- **Opções:**
  - A: …
  - B: …
  - C: … (se houver)
- **Recomendado:** A — <motivo em 1 frase>
- **Status:** proposto

### D2 — …
…
```

Regras da lista:

- Cubra dependências entre decisões (se D3 depende de D1, diga).
- Opções reais, não falsas dicotomias.
- Sempre um **Recomendado** com motivo curto.
- Vocabulário alinhado ao `CONTEXT.md`; se houver conflito de termo, resolva na lista (recomendando o canônico).
- Inclua ramos de **confirmação antes de ação irreversível** e **feedback acessível** (voz/TTS) quando a fatia agir no SO ou enviar dados.

Ainda **não** peça confirmação do usuário neste passo.

### 1.3 Repensar o conjunto (passagem 2)

Com a lista completa, releia **tudo** de ponta a ponta e revise o mesmo arquivo:

- Contradições entre recomendações
- Lacunas (ramos esquecidos)
- Opções fracas ou redundantes
- Impacto de uma escolha nas demais

Atualize `decisions.md` no lugar (mude recomendações, una/elimine entradas, marque o que mudou).

Ao final da passagem 2, adicione:

```markdown
## Revisão global
- Data/hora da passagem 2
- O que mudou vs passagem 1 (bullets)
- Riscos remanescentes (se houver)
```

Opcional (lazy, só se couber):

- Atualizar `CONTEXT.md` com termos **já resolvidos** na lista (formato em `CONTEXT-FORMAT.md`)
- Oferecer ADR só se for hard-to-reverse + surpreendente + trade-off real (`ADR-FORMAT.md`)

---

## Fase 2 — Confirmação

**Modelo:** Grok 4.5 High.

Mostre o conteúdo consolidado de `decisions.md` (ou um resumo + caminho do arquivo) e peça confirmação explícita.

Template de fechamento no chat:

```markdown
## Perguntas e decisões

| # | Pergunta | Recomendado | Override do usuário |
|---|----------|-------------|---------------------|
| D1 | … | … | (vazio = aceito) |

## Escopo da implementação
- Comportamentos a cobrir (unit): …
- Fora de escopo: …
- Modelo na próxima fase: Composer 2.5 (trocar no picker)
```

**Pare aqui** até o usuário confirmar ou ajustar. Aplique overrides no `decisions.md` (`Status: confirmado` / `Status: override — …`).

Só então vá para a Fase 3. A implementação segue as recomendações confirmadas.

---

## Fase 3 — TDD unitário → implementação

**Modelo:** Composer 2.5. Peça a troca antes de editar código.

Siga `tdd`:

1. Planeje comportamentos e interface pública; alinhe com `CONTEXT.md` / ADRs / `decisions.md`.
2. **Vertical slices**: um teste → implementação mínima → próximo. Proibido escrever todos os testes e depois toda a impl.
3. RED → GREEN; refactor só em GREEN.
4. Testes de comportamento via interface pública (não detalhes internos).
5. Separe portas que chamariam LLM/STT/TTS atrás de interfaces stubáveis (o e2e da Fase 6 não deve bater em API real).

Aplique o **loop de correção** se um teste ou implementação emperrar no mesmo erro.

---

## Fase 4 — Revisão de código

**Modelo:** Grok 4.5 High. Peça a troca antes do review.

Revise o diff da feature (base combinada com o usuário, default `main`):

- Eixos: **Standards** (convenções do repo) e **Spec** (`decisions.md` confirmado + comportamentos acordados).
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

**Escrever** e2e: Composer 2.5 se ainda estiver editando. **Rodar** e2e: sem IA.

Regras:

1. Descubra a stack e2e do repo (Playwright, Cypress, etc.) e os padrões existentes.
2. Cubra o **caminho feliz** da feature acordada (e só edge cases críticos se já fizerem parte do escopo).
3. E2E **não** chama LLM/STT/TTS reais — use stubs, fixtures, doubles; assert em efeitos observáveis (processo, DOM, arquivo, log).
4. Escreva e rode os e2e; corrija com o **loop de correção**.

Se o projeto não tiver e2e: proponha o mínimo viável no padrão mais próximo do repo, confirme com o usuário, então implemente.

---

## Fase 7 — Caminho feliz manual

Explique o passo a passo para o usuário validar na mão (usuário-alvo real ou proxy):

```markdown
## Caminho feliz (manual)

Pré-requisitos: …

1. …
2. …
3. …

Resultado esperado: …
```

Seja concreto (URLs, comandos, dados de exemplo). Um caminho feliz claro. Se a fatia for de acessibilidade, inclua o fluxo por voz/sem olhar a tela.

---

## Entrega final

Ao concluir (ou ao parar por erro repetido), entregue nesta ordem:

1. Status do pipeline (qual fase terminou / onde parou) + modelos usados por fase.
2. Caminho de `decisions.md` (se existir).
3. Tabela de bugs (diário).
4. Caminho feliz manual (se chegou na Fase 7).
5. Próximo passo sugerido só se bloqueado (ex.: próxima fatia MVP-B).

Não faça commit/PR a menos que o usuário peça.
