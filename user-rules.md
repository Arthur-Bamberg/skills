# User Rules (backup)

Backup de **regras globais** do assistente de IA (User Rules / instruções persistentes).

Nenhuma ferramenta carrega este arquivo automaticamente. Em máquina nova, cole o bloco abaixo na UI da sua ferramenta (ex.: Cursor → Settings → Rules → User Rules).

Última exportação: 2026-07-22

---

## Conteúdo para colar nas User Rules

```text
## Preferência de modelos (feature-loop)
Isto é preferência de fluxo — a ferramenta não troca o modelo sozinho via rule. Em cada fase, use (ou peça troca no picker / subagent com o modelo certo):

- **Decisões / plano / review:** Grok 4.5 High
- **Implementação (TDD):** Composer 2.5
- **E2E caminho feliz:** testes locais sem chamar LLM real (stubs/fixtures)
- Prefira pool First-party (Composer / Grok) em vez de modelos API caros, salvo necessidade explícita.
```

## Como restaurar

1. Abra as User Rules da sua ferramenta (ex.: Cursor Settings → Rules → User Rules)
2. Cole o conteúdo do bloco `text` acima (sem as fences)
3. Salve

## Manutenção

Quando alterar a regra na ferramenta, atualize este arquivo (sem sync automático).
