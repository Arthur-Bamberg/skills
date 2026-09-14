---
name: grillzinho
description: Lê CONTEXT.md e ADRs do tema, faz no máximo 5 perguntas de domínio de uma vez (com recomendação), atualiza glossário/ADRs e trata infra só via AGENTS.md até clareza do que fazer. Use when the user mentions grillzinho, /grillzinho, clareza de domínio, ou quer um grill curto antes de implementar.
disable-model-invocation: true
---

# Grillzinho

Grill curto: **no máximo 5 perguntas de domínio**, todas de uma vez, até ficar claro o que deve ser feito.

## Objetivo

Clareza completa do escopo/domínio do pedido — não implementar ainda. Ao fim das respostas: resumo do que fazer + docs atualizados.

## Fluxo

### 1. Localizar o projeto

Se o workspace não for o repo do tema, pergunte o path **uma vez** e mova para lá antes de ler docs.

### 2. Ler docs do tema (obrigatório, antes de perguntar)

Checklist:

```
- [ ] CONTEXT-MAP.md / CONTEXT.md (ou ausência confirmada)
- [ ] ADRs vinculadas ao assunto (docs/adr/ raiz e por contexto)
- [ ] AGENTS.md (regras de infra/stack/comandos)
- [ ] Briefing curto: o que docs já fecham vs. o que falta
```

Layout típico: ver skill `grill-domain-docs` / estrutura abaixo.

**Single context:**

```
/
├── CONTEXT.md
├── AGENTS.md
└── docs/adr/
```

**Multi-context:** `CONTEXT-MAP.md` aponta para cada `CONTEXT.md` e `docs/adr/` local.

Só leia ADRs **relacionadas ao assunto** do pedido (título, termos, contexto). Não releia o catálogo inteiro sem motivo.

Se algo já está respondido em CONTEXT, ADR ou código, **não pergunte**.

### 3. Infra = AGENTS.md

Não abra perguntas de infraestrutura (stack, deploy, CI, comandos, layout de monorepo, padrões de teste) se o `AGENTS.md` já define.

- Siga o `AGENTS.md` do projeto.
- Se faltar e bloquear a clareza do *o quê*, no máximo **uma** das 5 perguntas pode ser sobre a lacuna — preferindo invariante de domínio por trás, não menu de tecnologias.
- Não invente infra fora do que o `AGENTS.md` permite.

### 4. Até 5 perguntas de domínio, de uma vez

Elabore **1–5** perguntas (nunca mais que 5) sobre o domínio do tema:

- Termos ambíguos vs. glossário
- Limites de contexto / ownership
- Invariantes, cenários-limite, o que está in/out do pedido
- Conflitos plano × CONTEXT × ADR (sem reabrir decisão já documentada sem motivo)

Formato (lote único):

```
❓ **Q1** - **<título>**: <corpo; opções se fizer sentido>

➡️ <recomendação em 1 frase>

---

❓ **Q2** - ...
```

Regras:

- Todas as perguntas do lote **agora**; espere as respostas antes de outro lote.
- Cada pergunta traz **recomendação**.
- Preferir o que destrava *o que deve ser feito*; pular curiosidade.
- Se com <5 já há clareza, pare — não complete o cupom.
- Segundo lote só se as respostas abrirem buracos novos e ainda faltar clareza (de novo ≤5). Raro.

### 5. Depois das respostas

1. **Resumo do que deve ser feito** — escopo, invariantes, out-of-scope, decisões fechadas. Sem implementar até o usuário pedir.
2. **Atualizar `CONTEXT.md`** na hora para termos resolvidos. Formato: [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md). Só glossário — zero detalhe de implementação.
3. **Oferecer ADR** só se os 3 testes passarem (difícil reverter + surpreende sem contexto + trade-off real). Formato: [ADR-FORMAT.md](ADR-FORMAT.md). Criar `docs/adr/` com preguiça.

## Durante

- Conflito com glossário → apontar na hora.
- Termo vago → propor canônico.
- Relação de domínio → cenário concreto.
- Código contradiz o que o usuário disse → confrontar com evidência (explore antes de perguntar).
