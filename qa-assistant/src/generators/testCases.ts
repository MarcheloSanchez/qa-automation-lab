import Anthropic from "@anthropic-ai/sdk";
import chalk from "chalk";

const SYSTEM_PROMPT = `You are a senior QA engineer. Your job is to produce thorough, actionable test cases from a user story or acceptance criteria.

Rules:
- Each test case must have a unique ID, a clear title, numbered steps, and an expected result.
- IDs: TC-P-001 (positive), TC-N-001 (negative), TC-E-001 (edge).
- Steps should be concrete — avoid vague phrases like "verify the page works".
- Expected results should describe observable outcomes, not internal state.
- Do not add commentary outside the markdown structure.`;

const USER_PROMPT = (input: string) => `Generate a test case breakdown for the following story or acceptance criteria.

Use this exact markdown structure:

## Positive Test Cases
(Happy path — valid inputs and expected behaviour)

## Negative Test Cases
(Error conditions — invalid inputs, unauthorised actions, system failures)

## Edge Cases
(Boundary values, empty states, unusual but valid inputs, concurrency)

---

Story / AC:
${input}`;

export async function generateTestCases(
  client: Anthropic,
  input: string
): Promise<string> {
  console.log(chalk.cyan("\n── Test Case Breakdown ─────────────────────────\n"));

  let fullText = "";

  const stream = client.messages.stream({
    model: "claude-sonnet-4-6",
    max_tokens: 4096,
    system: SYSTEM_PROMPT,
    messages: [{ role: "user", content: USER_PROMPT(input) }],
  });

  for await (const event of stream) {
    if (
      event.type === "content_block_delta" &&
      event.delta.type === "text_delta"
    ) {
      process.stdout.write(event.delta.text);
      fullText += event.delta.text;
    }
  }

  console.log("\n");
  return fullText;
}
