import fs from "fs";
import Anthropic from "@anthropic-ai/sdk";
import chalk from "chalk";
import { generateTestCases } from "../generators/testCases.js";
import { generateDorCheck } from "../generators/dorCheck.js";
import { saveArtifacts } from "../output/writer.js";

export async function analyzeCommand(
  textArg: string | undefined,
  options: { file?: string }
): Promise<void> {
  let input: string;

  if (options.file) {
    if (!fs.existsSync(options.file)) {
      console.error(chalk.red(`File not found: ${options.file}`));
      process.exit(1);
    }
    input = fs.readFileSync(options.file, "utf8").trim();
  } else if (textArg) {
    input = textArg.trim();
  } else {
    console.error(chalk.red("Provide a story as an argument or via --file."));
    process.exit(1);
  }

  if (!input) {
    console.error(chalk.red("Input is empty."));
    process.exit(1);
  }

  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    console.error(chalk.red("ANTHROPIC_API_KEY is not set. Copy .env.example to .env and add your key."));
    process.exit(1);
  }

  const client = new Anthropic({ apiKey });

  console.log(chalk.bold("\nQA Assistant — Analyzing story...\n"));
  console.log(chalk.dim(`Input (first 200 chars): ${input.slice(0, 200)}`));

  const [testCases, dorCheck] = await Promise.all([
    generateTestCases(client, input),
    generateDorCheck(client, input),
  ]);

  const outputDir = saveArtifacts(testCases, dorCheck, input);
  console.log(chalk.green(`\nArtifacts saved to: ${outputDir}`));
}
