#!/usr/bin/env bash
# Generic notifier: optional args override title and body. Consumes hook stdin, prints {}.
# Usage: notify.sh [title] [body]
# Example: ./hooks/notify.sh "Cue-Me 提醒" "本轮已结束"
set -euo pipefail
input=$(cat || true)
export CURSOR_NOTIFY_TITLE="${1:-${CURSOR_NOTIFY_TITLE:-Cue-Me 提醒}}"
export CURSOR_NOTIFY_BODY="${2:-${CURSOR_NOTIFY_BODY:-本轮已结束，请回到 Cursor 查看。}}"
printf '%s' "$input" | "$(dirname "$0")/notify.py"
