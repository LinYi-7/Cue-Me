#!/usr/bin/env bash
# Wrapper for ~/.cursor/hooks — sets copy for the stop event.
export CURSOR_NOTIFY_TITLE="${CURSOR_NOTIFY_TITLE:-Cue-Me 提醒}"
export CURSOR_NOTIFY_BODY="${CURSOR_NOTIFY_BODY:-本轮 Agent 已结束，请回到 Cursor 查看。}"
exec "$(dirname "$0")/notify.py"
