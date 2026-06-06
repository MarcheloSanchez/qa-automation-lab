import fs from "fs";
import path from "path";

export function saveArtifacts(
  testCases: string,
  dorCheck: string,
  inputSummary: string
): string {
  const timestamp = new Date()
    .toISOString()
    .replace(/[:.]/g, "-")
    .slice(0, 19);

  const dir = path.join(process.cwd(), "output", timestamp);
  fs.mkdirSync(dir, { recursive: true });

  const header = `<!-- Input: ${inputSummary.slice(0, 120).replace(/\n/g, " ")} -->\n\n`;

  fs.writeFileSync(path.join(dir, "test-cases.md"), header + testCases, "utf8");
  fs.writeFileSync(path.join(dir, "dor-checklist.md"), header + dorCheck, "utf8");

  return dir;
}
