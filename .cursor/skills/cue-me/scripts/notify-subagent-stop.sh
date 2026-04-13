#!/usr/bin/env bash
# Optional wrapper for subagentStop — can be noisy if you use many subagents.
export CURSOR_NOTIFY_TITLE="${CURSOR_NOTIFY_TITLE:-Cue-Me 提醒}"
export CURSOR_NOTIFY_BODY="${CURSOR_NOTIFY_BODY:-子任务已结束，请到 Cursor 查看。}"
exec "$(dirname "$0")/notify.py"
