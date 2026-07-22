# Template — MVPs em fatias

Preencha e grave neste formato. Seções de **Custo Cursor** e **Tempo Cloud Agent** ficam no **topo**.

```markdown
## Custo Cursor (estimativa de uso do plano)

**Resumo:** pipeline recomendado = Grok 4.5 High (planejar/validar) + Composer 2.5 (implementar) + e2e local **sem IA** → pool **First-party**. Enquanto First-party aguentar: **~0% do budget API**. Número confiável = **$ equivalente**; % First-party é chute (pool “generous” não público).

**Comparativo:** se a **impl** rodasse em GPT-5.4 Nano (pool **API**), o $ de impl cai (~0,47× vs Composer no blend 70/30), mas consome API e **não** é o pipeline de entrega (Nano perde ~23 pts em Terminal-Bench 2.0 vs Composer).

**Direcionamento de modelo:** a IA **não troca o modelo sozinho**. Em cada fase do `/feature-loop`, peça ao usuário trocar no picker se o chat estiver no modelo errado.

### Preços de referência
| Modelo | Input / 1M | Cache read / 1M | Output / 1M | Pool |
|--------|------------|-----------------|-------------|------|
| Composer 2.5 | $0.50 | $0.20 | $2.50 | First-party |
| Grok 4.5 | $2.00 | $0.50 | $6.00 | First-party |
| GPT-5.4 Nano | $0.20 | $0.02 | $1.25 | API |
| E2E local sem IA | $0 | — | $0 | — |

Refs: https://cursor.com/docs/models-and-pricing · canvas `canvases/composer-2-5-vs-gpt-5-4-nano.canvas.tsx` (repo skills) · https://cursor.com/dashboard

### Cenário A — recomendado (Grok + Composer, First-party)
| Fatia | Plan (Grok) | Impl (Composer) | Review (Grok) | E2E | **Total $** |
|-------|-------------|-----------------|---------------|-----|-------------|
| **MVP-A** | $… | $… | $… | $0 | **~$…** |
| **MVP-B** | $… | $… | $… | $0 | **~$…** |
| **MVP-C** | $… | $… | $… | $0 | **~$…** |
| **A→…** | | | | | **~$…** |

### Cenário B — comparativo (impl em GPT-5.4 Nano, API)
Mesmo plan/review em Grok; só a coluna **Impl** escalada (~0,47× do $ Composer da mesma fatia). **Não usar como pipeline de entrega.**

| Fatia | Plan (Grok) | Impl (Nano) | Review (Grok) | E2E | **Total $** | Pool do impl |
|-------|-------------|-------------|---------------|-----|-------------|--------------|
| **MVP-A** | $… | $… | $… | $0 | **~$…** | API |
| **MVP-B** | $… | $… | $… | $0 | **~$…** | API |
| **MVP-C** | $… | $… | $… | $0 | **~$…** | API |
| **A→…** | | | | | **~$…** | |

### % do plano Cursor
| Referência | MVP-A (A) | Programa A→… (A) | MVP-A (B Nano impl) | Programa (B) |
|------------|-----------|------------------|---------------------|--------------|
| Pool **API** — Cenário A | **~0%** | **~0%** (até First-party acabar) | — | — |
| Pool **API** — Cenário B (só $ de Impl Nano) | — | — | ~…% de $20/$70/$400 | ~…% |
| Spillover no **Pro ($20)** se First-party acabar (A) | ~…% | … | — | — |
| Spillover no **Pro+ ($70)** (A) | ~…% | … | — | — |
| Spillover no **Ultra ($400)** (A) | ~…% | … | — | — |
| % **First-party** (chute, A) | ~…% | ~…% | Grok só | Grok só |

### Como ler
1. Entregar pelo **Cenário A**. Cenário B é só para comparar preço de API barata.
2. Melhor caso A (First-party ok): programa ≈ 0% API + fração do First-party.
3. Cenário B: cada $ de Impl Nano come o included API do plano.
4. E2E sem IA não consome modelo; escrever e2e consome Composer (A) ou Nano (B).
5. Nano ≠ modelo principal de agente — ver canvas / user rule.

---

## Tempo em Cloud Agent (rodando direto)

Wall-clock do agent **entre** gates humanos do `/feature-loop` (assume Cenário A / Composer na impl).

| Fatia | Tempo agent contínuo | Calendário c/ gates | Notas |
|-------|----------------------|---------------------|-------|
| **MVP-A** | ~… h | … | |
| **MVP-B** | ~… h | … | |
| **MVP-C** | ~… h | … | |
| **A→…** | ~… h | ~… dias | |

### Breakdown típico por feature-loop
| Fase | Modelo (pedir troca se preciso) | Cloud Agent |
|------|---------------------------------|-------------|
| Decisões em lote | Grok 4.5 High | ~20–45 min (ajustar) |
| *Gate humano* | — | pausa |
| TDD + impl | Composer 2.5 | … |
| Review + correções | Grok 4.5 High | … |
| Suite local + escrever e2e | Composer 2.5 | … |
| Rodar e2e (sem IA) | — | … |
| Caminho feliz manual | humano | fora do agent |

### Como ler
1. “Direto” ≠ calendário completo — gates humanos pausam.
2. Mesma assinatura de erro 2× → parar (regra feature-loop).
3. Cloud Agent concentra o burn First-party; não zera custo.
4. Se o chat estiver no modelo errado: *“Troque o modelo para **&lt;modelo&gt;** e confirme para eu continuar.”*

---

**Escopo:** <ideia em 1 frase>

**Âncora:** <por que importa>

**Tipo de trabalho:** **não é spike.** Programa de **MVPs em fatias verticais** (tracer bullets) com `/feature-loop`.
- Planejar: Grok 4.5 High *(pedir troca no picker se a IA não puder)*
- Implementar: Composer 2.5 *(idem)*
- Validar código: Grok 4.5 High *(idem)*
- E2E: testes locais **sem IA** no caminho feliz
- **Não** usar GPT-5.4 Nano como agente principal (só comparativo de custo acima)

Spike só como fase 0 **curta** se incerteza técnica dura.

---

## Decisões fechadas
- …

## Pipeline por fatia
1. Decisões em lote (Grok 4.5 High) → `decisions.md`
2. Confirmação humana
3. TDD + impl (Composer 2.5)
4. Review standards+spec (Grok 4.5 High)
5. Suite local (format/lint/typecheck/unit)
6. E2E local sem IA
7. Caminho feliz manual (usuário-alvo ou proxy)

## Opções de MVP

### MVP-A — “<nome>” (recomendado como 1º)
- **O quê:** …
- **Valor:** …
- **Esforço:** ~… feature-loop(s) / … dias
- **Risco:** baixo | médio | alto
- **E2E sem IA:** …

### MVP-B — “<nome>”
- …

(repita)

## Estimativa de valor (heurística)
| MVP | Valor âncora (1–5) | Reuso técnico (1–5) | Esforço (1–5) | Score (valor×2 − esforço) |
|-----|--------------------|---------------------|---------------|---------------------------|
| A | | | | |
| B | | | | |

**Ordem recomendada:** A → B → …

## Decisões em aberto
- …

## Hipótese da fatia A
…

## Critérios de sucesso (MVP-A)
- 1 caminho feliz e2e local verde **sem** LLM real
- Demo manual: …

## Achados
- _ainda não iniciou implementação_

## Próximo passo
- Confirmar ordem → `/feature-loop` na fatia A em repo dedicado
```
