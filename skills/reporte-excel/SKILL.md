---
name: reporte-excel
description: Gera linha de relatório Excel com lista de tickets Jira (vírgula) e uma observação única em pt-BR. Use quando o usuário pedir report excel, relatório diário, observação para planilha, tickets alterados, ou /reporte-excel.
---

# Reporte Excel (Jira)

Gera saída pronta para colar em planilha de report diário/semanal.

## Quando usar

- Usuário pede observação para Excel/report/planilha
- Lista de tickets mexidos na entrega atual
- Formato "1 observação para todos" (padrão) ou por ticket (se pedir)

## Regras de conteúdo

1. **Idioma:** pt-BR.
2. **Tickets:** chaves Jira (`PAG-509`), separadas por vírgula e espaço: `PAG-509, PAG-527, PAG-761`.
3. **Observação única (padrão):** uma frase que resume o trabalho do bloco de tickets.
4. **Limite de caracteres:** **100** por padrão; **50** só se o usuário pedir explicitamente.
5. **Não incluir** nomes de revisor/reviewer/assignee, salvo pedido explícito.
6. **Foco:** o que foi feito + status relevante (ex.: code review, em andamento, concluído).
7. **Conciso:** sem PR links, sem tabelas longas, sem markdown pesado — texto direto para colar.

## Como montar a observação

1. Identificar tickets da entrega (git branch, conversa, Jira, handoff).
2. Agrupar pelo **mesmo tema/entrega** (ex.: migração auth/perfis).
3. Redigir **uma** observação: escopo + resultado/status.
4. Contar caracteres; se passar do limite, encurtar mantendo sentido.

### Verbos úteis

- implementado, enviado para code review, corrigido, refatorado, migrado, ajustado, validado

### Evitar

- "Victor revisor", "assignee Arthur"
- listar cada repo/PR na observação (só na conversa se pedirem)
- jargão interno sem contexto (ADR, smoke) se couber resumo mais claro

## Formato de saída (padrão)

Entregar exatamente neste layout, sem tabela:

```
**Tickets:**
PAG-509, PAG-527, PAG-761

**Observação:**
Migração auth/perfis: usuários, regras CRUD e empty state — implementado e em code review
```

Se o usuário pedir **só a lista** ou **só a observação**, entregar apenas o bloco pedido.

## Variantes

### Por ticket (só se pedir)

Uma observação por linha, cada uma respeitando o limite de caracteres:

```
PAG-509	Migração auth/perfis (senhas 90 dias) enviada para code review
PAG-527	CRUD usuários: listagem/normalização enviada para code review
```

### Limite 50 caracteres

Aplicar o mesmo fluxo com teto de 50 chars na observação.

## Exemplo (conversa recente)

**Entrada:** tickets PAG-509, PAG-527, PAG-761 — migração auth/perfis, code review.

**Saída:**

```
**Tickets:**
PAG-509, PAG-527, PAG-761

**Observação:**
Migração auth/perfis: usuários, regras CRUD e empty state — implementado e em code review
```

(98 caracteres na observação.)

## Checklist antes de responder

- [ ] Tickets em ordem lógica (numérica ou cronológica)
- [ ] Lista separada por `, ` (vírgula + espaço)
- [ ] Uma observação única (salvo pedido contrário)
- [ ] ≤100 caracteres na observação (ou limite pedido)
- [ ] Sem nomes de pessoas, salvo pedido explícito
