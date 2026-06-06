import Anthropic from "@anthropic-ai/sdk";
import chalk from "chalk";

const SYSTEM_PROMPT = `You are a QA lead responsible for Definition of Ready (DoR) reviews. You check user stories before they enter a sprint.

Rules:
- Be specific — if something is missing, say exactly what is missing.
- Questions must be actionable — the team should be able to answer them.
- Do not invent information that is not in the story.
- Do not add commentary outside the markdown structure.`;

const DoR_CRITERIA = `
1. Story follows the standard format: "As a [user], I want [action], so that [value]"
2. Acceptance criteria are explicit and individually testable
3. Business value / purpose is clearly stated
4. Scope boundaries are defined (what is in scope vs out of scope)
5. Dependencies on other stories, services, or teams are identified
6. Non-functional requirements are addressed (performance, security, accessibility)
7. UI/UX designs or wireframes are available (if the story touches the UI)
8. Story is small enough to be completed within one sprint
9. Error scenarios and edge cases are mentioned in the AC
10. Technical unknowns or potential blockers are identified
`;

const USER_PROMPT = (input: string) => `Review the following story against the Definition of Ready criteria below.

For each criterion use one of: ✅ Met | ⚠️ Partial | ❌ Missing

Then list every ❌ or ⚠️ item as a concrete checkbox question the team must answer before the story is sprint-ready.

Use this exact markdown structure:

## DoR Criteria Review

| # | Criterion | Status | Note |
|---|-----------|--------|------|
(one row per criterion)

## Questions to Answer Before Development

- [ ] (one question per gap — be specific)

---

DoR Criteria:
${DoR_CRITERIA}

Story / AC:
${input}`;

export async function generateDorCheck(
  client: Anthropic,
  input: string
): Promise<string> {
  console.log(chalk.yellow("\n── Definition of Ready Check ───────────────────\n"));

  let fullText = "";

  const stream = client.messages.stream({
    model: "claude-sonnet-4-6",
    max_tokens: 2048,
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
