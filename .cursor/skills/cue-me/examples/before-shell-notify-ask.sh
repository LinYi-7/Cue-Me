#!/usr/bin/env bash
# Optional: copy to ~/.cursor/hooks/ and merge into hooks.json under beforeShellExecution.
# When a shell command matches the matcher, sends a macOS notification, then asks user in Cursor.
# Based on create-hook approve-network pattern + notification before ask.
set -euo pipefail
TN="${TERMINAL_NOTIFIER:-$HOME/.cursor/hooks/terminal-notifier.app/Contents/MacOS/terminal-notifier}"
SENDER="${CURSOR_NOTIFY_SENDER:-com.todesktop.230313mzl4w4u92}"
input=$(cat)
command=$(printf '%s' "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('command') or '')")

if [[ "$command" =~ curl|wget|nc\  ]]; then
  if [[ -x "$TN" ]]; then
    "$TN" -title "Cue-Me 提醒" -message "请在 Cursor 中批准网络相关命令" -sender "$SENDER" 2>/dev/null || true
  else
    /usr/bin/osascript -e 'display notification "请在 Cursor 中批准网络相关命令" with title "Cue-Me 提醒"' 2>/dev/null || true
  fi
  echo '{
    "permission": "ask",
    "user_message": "This command may make a network request. Please review it before continuing.",
    "agent_message": "A hook flagged this shell command as a possible network call."
  }'
  exit 0
fi

echo '{ "permission": "allow" }'
exit 0
