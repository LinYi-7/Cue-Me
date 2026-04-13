#!/usr/bin/env python3
"""
macOS user notification for Cursor hooks. Safe AppleScript string escaping.
Reads stdin (hook JSON) and discards — keeps stdin drained for pipe protocol.
Prints '{}' to stdout for events that expect JSON (e.g. stop).
"""
from __future__ import annotations

import os
import subprocess
import sys

# Same bundle id as Cursor.app — makes notifications use System Settings → Cursor (not Script Editor).
_DEFAULT_SENDER = "com.todesktop.230313mzl4w4u92"
_DEFAULT_TN = os.path.expanduser(
    "~/.cursor/hooks/terminal-notifier.app/Contents/MacOS/terminal-notifier"
)


def _notify(title: str, body: str) -> None:
    sender = os.environ.get("CURSOR_NOTIFY_SENDER", _DEFAULT_SENDER)
    tn = os.environ.get("TERMINAL_NOTIFIER", _DEFAULT_TN)
    if os.path.isfile(tn) and os.access(tn, os.X_OK):
        subprocess.run(
            [tn, "-title", title, "-message", body, "-sender", sender],
            check=False,
        )
        return
    def esc(s: str) -> str:
        return s.replace("\\", "\\\\").replace('"', '\\"')

    script = f'display notification "{esc(body)}" with title "{esc(title)}"'
    subprocess.run(["/usr/bin/osascript", "-e", script], check=False)


def main() -> None:
    _ = sys.stdin.read()

    title = os.environ.get("CURSOR_NOTIFY_TITLE", "Cue-Me 提醒")
    body = os.environ.get(
        "CURSOR_NOTIFY_BODY",
        "Agent 已停止，请回到 Cursor 查看。",
    )

    _notify(title, body)
    print("{}")


if __name__ == "__main__":
    main()
