import "dotenv/config";
import { Command } from "commander";
import { analyzeCommand } from "./commands/analyze.js";

const program = new Command();

program
  .name("qa-assistant")
  .description("AI-powered QA assistant: generates test cases and DoR checklists from plain-text stories")
  .version("0.1.0");

program
  .command("analyze [text]")
  .description("Analyze a user story or AC — outputs test cases and a DoR checklist")
  .option("-f, --file <path>", "Read story from a file instead of inline text")
  .action(analyzeCommand);

program.parse();
