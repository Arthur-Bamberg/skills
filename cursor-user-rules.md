# Cursor User Rules (backup)

Backup das **User Rules** globais do Cursor (Settings → Rules → User Rules).

O Cursor **não** carrega este arquivo automaticamente. Em máquina nova, cole o bloco abaixo de volta no Settings.

Última exportação: 2026-07-22

---

## Conteúdo para colar em Settings → Rules → User Rules

```text
## Preferência de modelos (feature-loop)
Isto é preferência de fluxo — o Cursor não troca o modelo sozinho via rule. Em cada fase, use (ou peça troca no picker / subagent com o modelo certo):

- **Decisões / plano / review:** Grok 4.5 High
- **Implementação (TDD):** Composer 2.5
- **E2E caminho feliz:** testes locais sem chamar LLM real (stubs/fixtures)
- Prefira pool First-party (Composer / Grok) em vez de modelos API caros, salvo necessidade explícita.
```

## Como restaurar

1. Abra **Cursor Settings → Rules → User Rules**
2. Cole o conteúdo do bloco `text` acima (sem as fences)
3. Salve

## Manutenção

Quando alterar a User Rule no Settings, atualize este arquivo (não há sync automático — o Cursor não expõe User Rules como arquivo em `~/.cursor/`).
