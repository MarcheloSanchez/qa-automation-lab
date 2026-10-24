#!/bin/bash
# Installs Python dependencies so Robot Framework tests and ruff work in
# Claude Code cloud sessions. Local sessions are skipped - use your own venv.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

python -m pip install --quiet --disable-pip-version-check -r requirements.txt

# Browser library's Node side (rfbrowser init) and the app submodule are
# deliberately not set up here: both are slow and only needed for UI tests
# or a local app instance. See AGENTS.md for how to get them when needed.
