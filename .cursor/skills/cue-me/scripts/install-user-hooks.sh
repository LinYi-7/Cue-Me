#!/usr/bin/env bash
# Copy notify scripts into ~/.cursor/hooks/ and create ~/.cursor/hooks.json if missing.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEST="${HOME}/.cursor/hooks"
mkdir -p "$DEST"

for f in notify.py notify.sh notify-stop.sh notify-subagent-stop.sh; do
  cp "$SCRIPT_DIR/$f" "$DEST/$f"
done
if [[ -f "$SKILL_ROOT/examples/before-shell-notify-ask.sh" ]]; then
  cp "$SKILL_ROOT/examples/before-shell-notify-ask.sh" "$DEST/before-shell-notify-ask.sh"
  chmod +x "$DEST/before-shell-notify-ask.sh"
fi
chmod +x "$DEST/notify.py" "$DEST/notify.sh" "$DEST/notify-stop.sh" "$DEST/notify-subagent-stop.sh"

HOOKS_JSON="${HOME}/.cursor/hooks.json"
if [[ ! -f "$HOOKS_JSON" ]]; then
  cp "$SKILL_ROOT/examples/hooks.user.json" "$HOOKS_JSON"
  echo "Created $HOOKS_JSON"
else
  echo "NOTE: $HOOKS_JSON already exists. Merge the stop hook from $SKILL_ROOT/examples/hooks.user.json manually if needed."
fi

install_terminal_notifier() {
  local app="$DEST/terminal-notifier.app"
  local zip="${TMPDIR:-/tmp}/terminal-notifier-2.0.0.zip"
  if [[ -x "$app/Contents/MacOS/terminal-notifier" ]]; then
    return 0
  fi
  curl -fsSL -o "$zip" "https://github.com/julienXX/terminal-notifier/releases/download/2.0.0/terminal-notifier-2.0.0.zip"
  rm -rf "${TMPDIR:-/tmp}/tn-unzip-$$"
  mkdir -p "${TMPDIR:-/tmp}/tn-unzip-$$"
  unzip -q -o "$zip" -d "${TMPDIR:-/tmp}/tn-unzip-$$"
  rm -rf "$app"
  cp -R "${TMPDIR:-/tmp}/tn-unzip-$$/terminal-notifier.app" "$app"
  chmod +x "$app/Contents/MacOS/terminal-notifier"
  rm -rf "${TMPDIR:-/tmp}/tn-unzip-$$"
  echo "Installed terminal-notifier.app (notifications use Cursor in System Settings)."
}

install_terminal_notifier || echo "WARNING: terminal-notifier install failed; notifications may fall back to osascript (Script Editor)." >&2

echo "Installed hooks into $DEST"
