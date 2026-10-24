"""Summarise which known defects of sprint5-with-bugs the suite detected.

Tests tagged ``bug:<id>`` assert correct behaviour, so against the buggy app a
FAIL means the defect was caught. Untagged tests in the same run act as
controls: they must pass on the buggy app too, otherwise failures may come
from a broken environment rather than from the bugs, and the report is
marked invalid (exit code 1). Prints a Markdown report to stdout.

    python scripts/bug_scorecard.py output/output.xml \
        app/practice-software-testing/sprint5-with-bugs/testSessions/listOfBugs.md
"""

from __future__ import annotations

import argparse
from pathlib import Path

from robot.api import ExecutionResult, ResultVisitor

BUG_TAG_PREFIX = "bug:"


class BugTestCollector(ResultVisitor):
    def __init__(self) -> None:
        self.results: dict[str, list[tuple[str, str]]] = {}
        self.controls: list[tuple[str, str]] = []

    def visit_test(self, test) -> None:
        bug_tags = [tag for tag in test.tags if tag.lower().startswith(BUG_TAG_PREFIX)]
        if not bug_tags:
            self.controls.append((test.longname, test.status))
        for tag in bug_tags:
            bug_id = tag[len(BUG_TAG_PREFIX):]
            self.results.setdefault(bug_id, []).append((test.longname, test.status))


def load_bug_titles(bug_list: Path) -> dict[str, str]:
    titles: dict[str, str] = {}
    for line in bug_list.read_text(encoding="utf-8").splitlines():
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) > 2 and cells[0].isdigit():
            titles[cells[0]] = f"{cells[1]}: {cells[2]}"
    return titles


def bug_status(statuses: list[str]) -> str:
    if "FAIL" in statuses:
        return "caught"
    if "PASS" in statuses:
        return "missed"
    return "not run"


def broken_controls(controls: list[tuple[str, str]]) -> list[str]:
    if not controls:
        return ["(no control tests ran)"]
    return [name for name, status in controls if status != "PASS"]


def render(
    results: dict[str, list[tuple[str, str]]],
    titles: dict[str, str],
    broken: list[str],
) -> str:
    rows = []
    counts = {"caught": 0, "missed": 0, "not run": 0}
    for bug_id in sorted(results, key=lambda b: int(b) if b.isdigit() else 0):
        tests = results[bug_id]
        status = bug_status([status for _, status in tests])
        counts[status] += 1
        names = "<br>".join(name.split(".")[-1] for name, _ in tests)
        rows.append(f"| {bug_id} | {status} | {titles.get(bug_id, '?')} | {names} |")

    lines = ["## Bug scorecard (sprint5-with-bugs)", ""]
    if broken:
        lines += [
            "> **Invalid run:** control tests did not pass, so failures below may come",
            "> from the environment rather than the bugs: " + ", ".join(broken),
            "",
        ]
    lines += [
        (
            f"Caught **{counts['caught']}** of {len(results)} targeted bugs "
            f"({counts['missed']} missed, {counts['not run']} not run); "
            f"{len(titles) or '?'} bugs are listed in total."
        ),
        "",
        "| Bug | Result | Description | Tests |",
        "|---|---|---|---|",
        *rows,
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("output_xml", type=Path)
    parser.add_argument("bug_list", type=Path, nargs="?")
    args = parser.parse_args()

    collector = BugTestCollector()
    ExecutionResult(str(args.output_xml)).visit(collector)
    titles = load_bug_titles(args.bug_list) if args.bug_list else {}
    broken = broken_controls(collector.controls)
    print(render(collector.results, titles, broken))
    return 1 if broken else 0


if __name__ == "__main__":
    raise SystemExit(main())
