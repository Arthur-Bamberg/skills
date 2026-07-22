import {
  BarChart,
  Callout,
  Card,
  CardBody,
  CardHeader,
  Divider,
  Grid,
  H1,
  H2,
  H3,
  Link,
  Pill,
  Row,
  Stack,
  Stat,
  Table,
  Text,
  useHostTheme,
} from "cursor/canvas";

/**
 * Shared coding benchmarks where both models publish a score.
 * Terminal-Bench 2.0 is the cleanest head-to-head (same suite name).
 * SWE-Bench Pro: Nano from OpenAI; Composer 2.5 from third-party aggregators of Cursor evals.
 */
const sharedBenchmarks = {
  categories: ["Terminal-Bench 2.0", "SWE-Bench Pro"],
  series: [
    { name: "Composer 2.5", data: [69.3, 54.0], tone: "info" as const },
    { name: "GPT-5.4 Nano (xhigh)", data: [46.3, 52.4], tone: "neutral" as const },
  ],
};

/** USD per 1M tokens — Cursor pricing page / OpenAI launch post. */
const pricing = {
  categories: ["Input", "Cache read", "Output"],
  series: [
    { name: "Composer 2.5 Standard", data: [0.5, 0.2, 2.5], tone: "info" as const },
    { name: "GPT-5.4 Nano", data: [0.2, 0.02, 1.25], tone: "neutral" as const },
  ],
};

export default function Composer25VsGpt54Nano() {
  const theme = useHostTheme();

  return (
    <Stack gap={24} style={{ padding: 24, maxWidth: 960 }}>
      <Stack gap={8}>
        <Row gap={8} align="center" wrap>
          <H1 style={{ margin: 0 }}>Composer 2.5 vs GPT-5.4 Nano</H1>
          <Pill tone="info">Comparativo</Pill>
        </Row>
        <Text tone="secondary">
          Benchmarks e preços oficiais + fontes de terceiros. Nano ganha em
          tarifa de API; Composer ganha em coding agentico e no pool próprio do
          Cursor.
        </Text>
      </Stack>

      <Grid columns={4} gap={12}>
        <Stat
          value="+23 pts"
          label="Terminal-Bench (69.3 vs 46.3)"
          tone="success"
        />
        <Stat
          value="~2.5×"
          label="Nano mais barato no input"
          tone="warning"
        />
        <Stat value="Próprio" label="Pool Composer no Cursor" tone="info" />
        <Stat value="Subagente" label="Uso ideal do Nano" />
      </Grid>

      <Callout tone="info" title="Veredito rápido">
        Para implementar no Cursor com planejamento e testes:{" "}
        <Text weight="semibold">Composer 2.5</Text>. Nano só vale se o objetivo
        for minimizar custo de API em subtarefas estreitas e bem definidas —
        não como modelo principal de agente.
      </Callout>

      <Stack gap={8}>
        <H2>Benchmarks compartilhados (%)</H2>
        <Text tone="secondary" size="small">
          Fonte: OpenAI (Nano, effort xhigh) · Cursor/agregadores (Composer 2.5).
          Harnesses podem diferir; Terminal-Bench 2.0 é o sinal mais direto.
        </Text>
        <BarChart
          categories={sharedBenchmarks.categories}
          series={sharedBenchmarks.series}
          valueSuffix="%"
          yMax={100}
          height={220}
          showValues
        />
      </Stack>

      <Divider />

      <Stack gap={12}>
        <H2>Tabela lado a lado</H2>
        <Table
          headers={["Dimensão", "Composer 2.5", "GPT-5.4 Nano", "Vantagem"]}
          columnAlign={["left", "left", "left", "left"]}
          striped
          rows={[
            [
              "Provedor",
              "Cursor (pool próprio)",
              "OpenAI (pool API)",
              "Depende do uso",
            ],
            [
              "Input / Output ($/1M)",
              "$0.50 / $2.50 (Standard)\n$3 / $15 (Fast)",
              "$0.20 / $1.25",
              "Nano",
            ],
            [
              "Cache read ($/1M)",
              "$0.20",
              "$0.02 (90% off input)",
              "Nano",
            ],
            [
              "Terminal-Bench 2.0",
              "69.3%",
              "46.3% (xhigh)",
              "Composer",
            ],
            [
              "SWE-Bench Pro",
              "~54%",
              "52.4% (xhigh)",
              "Composer (leve)",
            ],
            [
              "SWE-Bench Multilingual",
              "79.8%",
              "—",
              "Só Composer",
            ],
            [
              "CursorBench v3.1",
              "63.2%",
              "—",
              "Só Composer",
            ],
            [
              "AA Coding Agent Index",
              "62 (~$0.07–$0.44/tarefa)",
              "—",
              "Só Composer",
            ],
            [
              "Toolathlon",
              "—",
              "35.5% (xhigh)",
              "Só Nano",
            ],
            [
              "GPQA Diamond",
              "—",
              "82.8% (xhigh)",
              "Só Nano",
            ],
            [
              "OSWorld-Verified",
              "—",
              "39.0% (xhigh)",
              "Só Nano",
            ],
            [
              "Contexto",
              "Até ~1M (reports)",
              "400K",
              "Composer (reports)",
            ],
            [
              "Posicionamento oficial",
              "Agente de coding no Cursor",
              "Classificação, extração, ranking, subagentes simples",
              "Composer p/ implementar",
            ],
          ]}
          rowTone={[
            undefined,
            "success",
            undefined,
            "info",
            "info",
            undefined,
            undefined,
            "info",
            undefined,
            undefined,
            undefined,
            undefined,
            "warning",
          ]}
        />
        <Text tone="secondary" size="small">
          “—” = score público não encontrado para o outro modelo na mesma
          suíte. SWE-Bench Pro do Composer vem de agregadores; confirme no
          harness usado.
        </Text>
      </Stack>

      <Stack gap={8}>
        <H2>Preço por 1M tokens (USD)</H2>
        <Text tone="secondary" size="small">
          Fonte:{" "}
          <Link href="https://cursor.com/pt-BR/docs/models-and-pricing">
            Cursor Models & Pricing
          </Link>
          {" · "}
          <Link href="https://openai.com/index/introducing-gpt-5-4-mini-and-nano/">
            OpenAI GPT-5.4 mini/nano
          </Link>
        </Text>
        <BarChart
          categories={pricing.categories}
          series={pricing.series}
          valuePrefix="$"
          height={200}
          showValues
        />
        <Grid columns={2} gap={12}>
          <Card>
            <CardHeader>Blend 70% in / 30% out</CardHeader>
            <CardBody>
              <Stack gap={6}>
                <Row justify="space-between">
                  <Text>GPT-5.4 Nano</Text>
                  <Text weight="semibold">~$0.52 / 1M</Text>
                </Row>
                <Row justify="space-between">
                  <Text>Composer 2.5 Standard</Text>
                  <Text weight="semibold">~$1.10 / 1M</Text>
                </Row>
                <Text tone="secondary" size="small">
                  Nano ~2× mais barato na tarifa. No Cursor, Composer ainda
                  costuma sair mais barato na prática por usar o pool próprio
                  generoso.
                </Text>
              </Stack>
            </CardBody>
          </Card>
          <Card>
            <CardHeader>Custo efetivo no Cursor</CardHeader>
            <CardBody>
              <Stack gap={6}>
                <Text>
                  Composer 2.5 → <Text weight="semibold">pool próprio</Text>
                </Text>
                <Text>
                  GPT-5.4 Nano → <Text weight="semibold">pool de API</Text>{" "}
                  (consome os ~US$ 20+ incluídos)
                </Text>
                <Text tone="secondary" size="small">
                  Para uso diário de agente, o pool importa mais que a tarifa
                  unitária.
                </Text>
              </Stack>
            </CardBody>
          </Card>
        </Grid>
      </Stack>

      <Divider />

      <Stack gap={12}>
        <H2>Quando usar cada um</H2>
        <Grid columns={2} gap={12}>
          <Card>
            <CardHeader trailing={<Pill tone="info">Recomendado</Pill>}>
              Composer 2.5
            </CardHeader>
            <CardBody>
              <Stack gap={8}>
                <Text>
                  Implementação, TDD, refactors, loops de teste e trabalho
                  agentico no IDE.
                </Text>
                <Text tone="secondary" size="small">
                  +23 pts em Terminal-Bench 2.0; treinado para coding no Cursor;
                  pool próprio.
                </Text>
              </Stack>
            </CardBody>
          </Card>
          <Card>
            <CardHeader trailing={<Pill tone="neutral">Nicho</Pill>}>
              GPT-5.4 Nano
            </CardHeader>
            <CardBody>
              <Stack gap={8}>
                <Text>
                  Subtarefas simples, classificação, extração, ranking, alto
                  volume com baixa latência.
                </Text>
                <Text tone="secondary" size="small">
                  OpenAI não recomenda como modelo principal de agente complexo.
                </Text>
              </Stack>
            </CardBody>
          </Card>
        </Grid>
      </Stack>

      <Stack gap={10}>
        <H2>Fontes e links</H2>
        <Grid columns={2} gap={12}>
          <Stack gap={6}>
            <H3>Oficiais</H3>
            <Link href="https://cursor.com/pt-BR/docs/models-and-pricing">
              Cursor — Modelos e preços
            </Link>
            <Link href="https://cursor.com/blog/composer-2-5">
              Cursor — Introducing Composer 2.5
            </Link>
            <Link href="https://openai.com/index/introducing-gpt-5-4-mini-and-nano/">
              OpenAI — GPT-5.4 mini e nano (benchmarks)
            </Link>
            <Link href="https://developers.openai.com/api/docs/models/gpt-5.4-nano">
              OpenAI API — GPT-5.4 nano
            </Link>
          </Stack>
          <Stack gap={6}>
            <H3>Benchmarks / comparativos</H3>
            <Link href="https://artificialanalysis.ai/articles/cursor-composer-2-5-coding-agent-index">
              Artificial Analysis — Composer 2.5 Coding Agent Index
            </Link>
            <Link href="https://www.llmreference.com/compare/composer-2-5/gpt-5.4">
              LLMReference — Composer 2.5 vs GPT-5.4
            </Link>
            <Link href="https://benchlm.ai/compare/composer-2-5-vs-gpt-5-4">
              BenchLM — Composer 2.5 vs GPT-5.4
            </Link>
            <Link href="https://aireleasetracker.com/model/cursor/composer-2-5">
              AI Release Tracker — Composer 2.5 benches
            </Link>
          </Stack>
        </Grid>
        <Text
          tone="secondary"
          size="small"
          style={{ color: theme.tokens.text.tertiary }}
        >
          Dados reunidos em jul/2026. Comparações GPT-5.4 (full) ≠ Nano — links
          GPT-5.4 full entram só como contexto de família.
        </Text>
      </Stack>
    </Stack>
  );
}
