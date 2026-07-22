---
name: mvp-plan-doc
description: Interviews the user one question at a time (grill-me style) and produces an MVP planning document with vertical slices, Cursor plan cost %, Cloud Agent wall-clock estimates, and a feature-loop delivery pipeline. Use when the user asks for an MVP plan doc, documento de MVP, planejar MVPs em fatias, estimativa de custo Cursor + cloud agent, or mentions /mvp-plan-doc.
disable-model-invocation: true
---

# MVP Plan Doc

Gera um **documento de planejamento de MVPs em fatias** (não spike), no formato de [template.md](template.md), após grill curto.

## Regras do grill

Siga o espírito de `grill-me`:

- Uma pergunta por vez.
- Em cada pergunta: opções reais + **recomendação** em 1 frase.
- Se o código/docs do repo respondem, explore e **não** pergunte.
- Pare o grill quando tiver o mínimo para preencher o template sem inventar âncora, escopo ou ordem das fatias.
- Idioma do doc = idioma do usuário (default pt-BR se o usuário falar português).

## Ordem das perguntas (pule o que já souber)

Resolver dependências nesta ordem; pule ramos já respondidos no chat/repo:

1. **Ideia em 1 frase** — o que será construído.
2. **Âncora** — por que importa (pessoal/negócio); pesa o ranking das fatias.
3. **Usuário do 1º demo** — dono real vs proxy.
4. **Plataforma do 1º MVP** — OS/device alvo.
5. **Destino do doc** — Notion (página pai URL/ID) vs markdown local (caminho).
6. Só se ainda ambíguo: **quantas fatias** (default 3–5) e se confirma pipeline padrão abaixo.

Não pergunte preços de modelo nem estrutura do template — isso é fixo.

## Pipeline padrão (aplicar salvo override)

| Fase | Modelo / modo |
|------|----------------|
| Decisões / plano | Grok 4.5 High |
| Implementação (TDD) | Composer 2.5 |
| Review código | Grok 4.5 High |
| E2E caminho feliz | testes locais **sem IA** |
| Entrega | `/feature-loop` por fatia |

Tipo de trabalho: **MVPs em fatias verticais (tracer bullets)**. Spike só como fase 0 curta se houver incerteza técnica dura.

## Depois do grill — escrever o documento

1. Propor **3–5 fatias** (A, B, C…) ordenadas por valor da âncora ÷ esforço.
2. Preencher **custo Cursor** e **tempo Cloud Agent** com as heurísticas de [template.md](template.md) (ajustar faixas se a fatia for claramente menor/maior).
3. Incluir tabela de score: `(valor_mãe_ou_âncora + valor_reuso) − esforço` ou a fórmula do template.
4. Listar decisões em aberto, critérios de sucesso da fatia A, próximo passo.
5. **Escrever o doc**:
   - **Notion:** criar página filha da página pai indicada (`notion-create-pages`), título `MVPs — <ideia curta>`, conteúdo = template preenchido. Se não houver MCP/auth, entregar markdown completo no chat e avisar.
   - **Local:** gravar o markdown no caminho combinado (ou `.scratch/mvp-plan-doc/<slug>.md`).
6. Mostrar o link/caminho e o conteúdo consolidado para conversar — **não** iniciar implementação nem feature-loop até o usuário pedir.

## Heurísticas rápidas (obrigatórias no topo do doc)

### Custo Cursor

- Composer 2.5 + Grok 4.5 → pool **First-party** (não API), até o First-party acabar.
- Enquanto First-party ok: **~0% do pool API** ($20 / $70 / $400).
- Publicar burn em **$** (confiável) e **%** (chute no First-party; API só no cenário de spillover).
- E2E sem IA = $0 de modelo; escrever e2e consome Composer.
- Taxas de referência (atualizar se docs Cursor mudarem): Composer 2.5 `$0.50` in / `$2.50` out por 1M; Grok 4.5 `$2` in / `$6` out por 1M. Links: https://cursor.com/docs/models-and-pricing

Faixas default de burn (feature-loop completo):

| Porte da fatia | $ total |
|----------------|---------|
| Pequena (tipo “abrir app + confirmar”) | ~$5–15 |
| Média (tela/OCR, ditado+send) | ~$15–40 |
| Grande (navegar UI / agente rico) | ~$40–80+ |
| Soma 3 fatias P+M+M | ~$35–95 |

### Tempo Cloud Agent (rodando direto)

Wall-clock de máquina **entre** gates humanos do feature-loop:

| Porte | Agent contínuo | Calendário c/ 1 gate |
|-------|----------------|----------------------|
| Pequena | ~2–6 h | mesmo dia |
| Média | ~8–18 h | 1–2 dias |
| Grande | ~16–30 h+ | 2–4 dias |
| 3 fatias P+M+M | ~18–42 h | ~3–7 dias |

Lembrar: confirmação humana pausa o “direto”; não deixar agent na mesma assinatura de erro 2×.

## Anti-padrões

- Não chamar o entregável de “spike” se o doc descreve MVPs + feature-loop + e2e.
- Não perguntar uma lista enorme de decisões de implementação (isso é feature-loop depois).
- Não inventar âncora emocional/negócio.
- Não começar código nesta skill.

## Checklist antes de entregar

- [ ] Custo Cursor no **início** do doc
- [ ] Tempo Cloud Agent no início (após custo)
- [ ] Fatias A… numeradas com valor/esforço/risco/e2e
- [ ] Ordem recomendada + critérios de sucesso da fatia A
- [ ] Link Notion ou caminho local + conteúdo mostrado para conversa
