#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.agents/skills"
REPORTS_DIR="$REPO_ROOT/reports"

mkdir -p "$SKILLS_DIR"
mkdir -p "$REPORTS_DIR"

echo "Installing skills to $SKILLS_DIR ..."

for skill_dir in "$REPO_ROOT"/*/; do
  skill_dir="${skill_dir%/}"
  if [ -f "$skill_dir/SKILL.md" ]; then
    skill_name="$(basename "$skill_dir")"
    echo "  -> $skill_name"
    rm -rf "$SKILLS_DIR/$skill_name"
    cp -r "$skill_dir" "$SKILLS_DIR/$skill_name"
  fi
done

if [ "${1:-}" == "--cron" ]; then
  echo ""
  echo "Setting up cron jobs ..."
  CRON_BLOCK="# Orca Automation - AI News Summary (daily 3:10pm)"
  SCRIPT_PATH="$REPO_ROOT/ai-news-automation/scripts/ai_news_summary.py"
  LOG_PATH="$REPORTS_DIR/ai_news_summary.log"

  existing="$(crontab -l 2>/dev/null || true)"
  cleaned="$(echo "$existing" | grep -v "$CRON_BLOCK" | grep -v "ai_news_summary.py" || true)"

  new_cron="$cleaned
$CRON_BLOCK
10 15 * * * /usr/bin/python3 $SCRIPT_PATH >> $LOG_PATH 2>&1"

  echo "$new_cron" | crontab -
  echo "  -> Cron entry added (10 15 * * *)."
fi

echo ""
echo "Done! Restart your Orca session to pick up new skills."
if [ "${1:-}" != "--cron" ]; then
  echo "Tip: run with --cron to also set up scheduled jobs."
fi
