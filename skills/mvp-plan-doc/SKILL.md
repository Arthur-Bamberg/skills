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
5. **Destino do doc** — **default: Notion** (pedir só URL/ID da página pai se não houver default abaixo). Markdown local só se o usuário pedir explicitamente.
6. Só se ainda ambíguo: **quantas fatias** (default 3–5) e se confirma pipeline padrão abaixo.

### Preferências do usuário (Arthur)
- **Destino do doc:** Notion (não perguntar Notion vs local; assumir Notion).
- **Página pai default:** `Ideias de Projetos` (dentro de `Personal`) — id `1a7169fd-ba57-80cb-91cd-e0aa00be4a12` · URL https://app.notion.com/p/1a7169fdba5780cb91cde0aa00be4a12 — só perguntar se o usuário indicar outro lugar.

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

### Direcionamento de modelo (pedir troca)

A skill **não troca o modelo sozinho**. No doc e no chat, deixe explícito o modelo de cada fase. Se o chat estiver no modelo errado (ou a IA não puder trocar), **peça ao usuário** trocar no picker e confirmar antes de seguir — mesmo padrão do `/feature-loop`.

**Não recomende GPT-5.4 Nano** como modelo principal de agente/implementação (só subtarefas estreitas). Use Nano apenas no **cenário de custo comparativo** do doc.

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

Sempre publicar **dois cenários** no topo do doc (template):

1. **Recomendado (First-party):** Grok 4.5 + Composer 2.5 — pool próprio; ~0% API enquanto First-party aguentar.
2. **Comparativo GPT-5.4 Nano (API):** mesma fatia se a **impl** rodasse em Nano — tarifa menor, mas consome pool **API** e **não** é o pipeline recomendado.

Dados de referência (repo `Arthur-Bamberg/skills`, canvas `canvases/composer-2-5-vs-gpt-5-4-nano.canvas.tsx` + [pricing Cursor](https://cursor.com/docs/models-and-pricing)):

| Modelo | Input / 1M | Cache read / 1M | Output / 1M | Pool |
|--------|------------|-----------------|-------------|------|
| Composer 2.5 Standard | $0.50 | $0.20 | $2.50 | First-party |
| Grok 4.5 | $2.00 | $0.50 | $6.00 | First-party |
| GPT-5.4 Nano | $0.20 | $0.02 | $1.25 | API |
| E2E local sem IA | $0 | — | $0 | — |

Heurística de conversão **Impl Composer → Impl Nano** (mesmo volume de tokens, blend ~70% in / 30% out):

- Composer blended ≈ **$1.10 / 1M**; Nano blended ≈ **$0.52 / 1M** → Nano ≈ **~0,47×** o $ de impl Composer.
- Plan + Review continuam em Grok (First-party) nos dois cenários, salvo o usuário pedir “tudo Nano” (desencorajado).
- Terminal-Bench 2.0: Composer **69.3%** vs Nano **46.3%** (~−23 pts) — por isso Nano só entra como **linha de custo**, não como recomendação de entrega.

Publicar burn em **$** (confiável) e **%** (chute no First-party; API no cenário Nano / spillover).

Faixas default de burn — cenário **recomendado** (feature-loop completo):

| Porte da fatia | $ total (Grok+Composer) | Impl só em Nano (estim.) | Programa se impl=Nano* |
|----------------|-------------------------|--------------------------|------------------------|
| Pequena | ~$5–15 | ~$2–7 | ~$4–12 |
| Média | ~$15–40 | ~$7–19 | ~$12–32 |
| Grande | ~$40–80+ | ~$19–38 | ~$32–65 |
| Soma 3 fatias P+M+M | ~$35–95 | — | ~$28–76 |

\*Plan+Review ainda em Grok; só a coluna de impl foi escalada por ~0,47×. No cenário Nano, o $ de impl conta no **pool API** (Pro $20 / Pro+ $70 / Ultra $400), não no First-party.

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

- [ ] Custo Cursor no **início** do doc (**dois** cenários: First-party + Nano comparativo)
- [ ] Direcionamento de modelo explícito (pedir troca no picker se a IA não puder)
- [ ] Tempo Cloud Agent no início (após custo)
- [ ] Fatias A… numeradas com valor/esforço/risco/e2e
- [ ] Ordem recomendada + critérios de sucesso da fatia A
- [ ] Link Notion ou caminho local + conteúdo mostrado para conversa
