# Template — MVPs em fatias

Preencha e grave neste formato. Seções de **Custo Cursor** e **Tempo Cloud Agent** ficam no **topo**.

```markdown
## Custo Cursor (estimativa de uso do plano)

**Resumo:** pipeline Grok 4.5 High (planejar/validar) + Composer 2.5 (implementar) + e2e local **sem IA** → pool **First-party**. Enquanto First-party aguentar: **~0% do budget API**. Número confiável = **$ equivalente**; % First-party é chute (pool “generous” não público).

### Preços de referência
| Modelo | Input / 1M | Output / 1M | Pool |
|--------|------------|-------------|------|
| Composer 2.5 | $0.50 | $2.50 | First-party |
| Grok 4.5 | $2.00 | $6.00 | First-party |
| E2E local sem IA | $0 | $0 | — |

Refs: https://cursor.com/docs/models-and-pricing · https://cursor.com/dashboard

### Burn estimado por fatia (feature-loop completo)
| Fatia | Plan (Grok) | Impl (Composer) | Review (Grok) | E2E | **Total $** |
|-------|-------------|-----------------|---------------|-----|-------------|
| **MVP-A** | $… | $… | $… | $0 | **~$…** |
| **MVP-B** | $… | $… | $… | $0 | **~$…** |
| **MVP-C** | $… | $… | $… | $0 | **~$…** |
| **A→…** | | | | | **~$…** |

### % do plano Cursor
| Referência | MVP-A | Programa (A→…) |
|------------|-------|----------------|
| Pool **API** (Pro $20 / Pro+ $70 / Ultra $400) | **~0%** | **~0%** (até First-party acabar) |
| Spillover no **Pro ($20)** | ~…% | … |
| Spillover no **Pro+ ($70)** | ~…% | … |
| Spillover no **Ultra ($400)** | ~…% | … |
| % **First-party** (chute) | ~…% | ~…% |

### Como ler
1. Melhor caso (First-party ok): programa ≈ 0% API + fração do First-party.
2. Pior caso (spillover): usar coluna $ total vs included API do plano.
3. E2E sem IA não consome modelo; escrever e2e consome Composer.

---

## Tempo em Cloud Agent (rodando direto)

Wall-clock do agent **entre** gates humanos do `/feature-loop`.

| Fatia | Tempo agent contínuo | Calendário c/ gates | Notas |
|-------|----------------------|---------------------|-------|
| **MVP-A** | ~… h | … | |
| **MVP-B** | ~… h | … | |
| **MVP-C** | ~… h | … | |
| **A→…** | ~… h | ~… dias | |

### Breakdown típico por feature-loop
| Fase | Cloud Agent |
|------|-------------|
| Decisões em lote (Grok) | ~20–45 min (ajustar) |
| *Gate humano* | pausa |
| TDD + impl (Composer) | … |
| Review (Grok) + correções | … |
| Suite local + escrever e2e | … |
| Rodar e2e (sem IA) | … |
| Caminho feliz manual | humano; fora do agent |

### Como ler
1. “Direto” ≠ calendário completo — gates humanos pausam.
2. Mesma assinatura de erro 2× → parar (regra feature-loop).
3. Cloud Agent concentra o burn First-party; não zera custo.

---

**Escopo:** <ideia em 1 frase>

**Âncora:** <por que importa>

**Tipo de trabalho:** **não é spike.** Programa de **MVPs em fatias verticais** (tracer bullets) com `/feature-loop`.
- Planejar: Grok 4.5 High
- Implementar: Composer 2.5
- Validar código: Grok 4.5 High
- E2E: testes locais **sem IA** no caminho feliz

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
