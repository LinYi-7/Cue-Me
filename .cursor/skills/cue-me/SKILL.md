---
name: cue-me
description: >-
  Cue-Me：在 macOS 上通过 Cursor 用户级 hooks 发送系统通知（默认标题「Cue-Me 提醒」、中文正文）。
  覆盖 Agent 停止（stop）、可选子代理停止，以及「需确认」场景说明与 beforeShellExecution 示例。
  在配置 Cursor hooks、Mac 通知或排查 Hooks 通道时使用。
---

# Cue-Me（Cursor 后台 Mac 通知）

## 目标

- **Agent 跑完**：`stop` 事件触发时发一条系统通知（默认 **Cue-Me 提醒** + 中文说明），便于你从后台回到 Cursor。
- **可选**：`subagentStop` 在子任务结束时提醒（可能较频繁）。
- **「需要确认」**：仅对**能通过 hook 表达为 `permission: ask`** 的流程可靠（见下文边界）。

## 前置条件

- 仅 **macOS**。
- 脚本依赖系统自带的 **Python 3**（`/usr/bin/env python3`）。
- **推荐**：安装脚本会下载 **`terminal-notifier.app`** 到 `~/.cursor/hooks/`，并用 **Cursor 的 Bundle ID**（`com.todesktop.230313mzl4w4u92`）发通知。这样横幅会走 **系统设置 → 通知 → Cursor**（与只给 Cursor 开权限一致）。  
  若仅用 `osascript` 的 `display notification`，系统往往把它算成 **「脚本编辑器」或 osascript**，**不会**用你在 Cursor 里设的规则，容易出现「角标有、右上角没横幅」。

## 若右上角仍没有横幅

1. 确认存在 **`~/.cursor/hooks/terminal-notifier.app`**，且 `lib.sh` / `notify.py` 已更新为优先调用它（安装脚本会下载）。
2. 在 **系统设置 → 通知 → Cursor** 中，样式选 **横幅** 或 **提醒**（你已选「提醒」也可以），并关闭「定时推送摘要」等对通知的合并/延迟（若开启）。
3. 检查 **专注模式 / 勿扰**，会话期间可能抑制横幅。
4. 仍不行时，在终端执行自检（应出现一条 **来自 Cursor 规则** 的通知）：

   ```bash
   ~/.cursor/hooks/terminal-notifier.app/Contents/MacOS/terminal-notifier \
     -title "Cue-Me 自检" -message "若看见这条，terminal-notifier + Cursor 发送方已生效" \
     -sender com.todesktop.230313mzl4w4u92
   ```

## 安装（用户级 hooks，全局生效）

**一键安装（推荐）**：在仓库内执行（会将脚本复制到 `~/.cursor/hooks/`，若不存在则创建 `~/.cursor/hooks.json`）：

```bash
bash .cursor/skills/cue-me/scripts/install-user-hooks.sh
```

若 `~/.cursor/hooks.json` 已存在，安装脚本**不会覆盖**；请手动把 [examples/hooks.user.json](examples/hooks.user.json) 中的 `stop` 段合并进去。

**手动安装**：将 `scripts/` 下文件复制到 `~/.cursor/hooks/`：

- `notify.py`（核心：优先 terminal-notifier + Cursor 发送方，回退 osascript；stdout `{}`）
- `notify.sh`（可选：`notify.sh [标题] [正文]`，默认 **Cue-Me 提醒** + 中文）
- `notify-stop.sh`
- `notify-subagent-stop.sh`（若需要子代理提醒）
- 可选：将 [examples/before-shell-notify-ask.sh](examples/before-shell-notify-ask.sh) 复制到 `~/.cursor/hooks/`（与「需确认」示例配套）

为脚本添加可执行权限：

```bash
chmod +x ~/.cursor/hooks/notify.py ~/.cursor/hooks/notify.sh ~/.cursor/hooks/notify-stop.sh
chmod +x ~/.cursor/hooks/notify-subagent-stop.sh
chmod +x ~/.cursor/hooks/before-shell-notify-ask.sh
```

在 `~/.cursor/hooks.json` 中注册 hook（见 [examples/hooks.user.json](examples/hooks.user.json)）。若已有其它 hooks，**合并** `hooks` 对象，勿覆盖无关条目。若同时使用 shell 审批通知，见 [examples/hooks.user.with-shell-ask.json](examples/hooks.user.with-shell-ask.json)。

最小 `hooks.json` 示例：

```json
{
  "version": 1,
  "hooks": {
    "stop": [{ "command": "./hooks/notify-stop.sh" }]
  }
}
```

保存后 Cursor 会重载；若不生效可重启 Cursor。在 **Hooks** 设置与 **Hooks** 输出通道中查看是否报错。

## 默认中文文案

| 变量 / 场景 | 默认标题 | 默认正文 |
|-------------|----------|----------|
| `notify.py` / `notify.sh` | Cue-Me 提醒 | Agent 已停止，请回到 Cursor 查看。 / 本轮已结束…（见脚本） |
| `notify-stop.sh` | Cue-Me 提醒 | 本轮 Agent 已结束，请回到 Cursor 查看。 |
| `notify-subagent-stop.sh` | Cue-Me 提醒 | 子任务已结束，请到 Cursor 查看。 |

可通过环境变量覆盖：

- `CURSOR_NOTIFY_TITLE`：通知标题。
- `CURSOR_NOTIFY_BODY`：通知正文。

## 能力边界（必读）

| 场景 | 是否容易用 hooks 通知 |
|------|------------------------|
| Agent 本轮结束 | 是，使用 **`stop`** |
| 子代理结束 | 是，使用 **`subagentStop`**（可选，可能吵） |
| 你的 hook 在 **`beforeShellExecution` / `beforeMCPExecution`** 里返回 `permission: ask` | 是，在**同一脚本**里先发通知再返回 `ask` |
| Cursor **内置**、且不经过你自定义 hook 的阻塞审批 UI | **不一定**有对应事件；无法保证纯 hooks 全覆盖 |

## 「需确认」示例（shell 审批时顺带通知）

完整可运行示例见 [examples/before-shell-notify-ask.sh](examples/before-shell-notify-ask.sh)。也可在返回 `permission: ask` **之前**自行调用 `osascript` 或 `notify.py`：

```bash
#!/usr/bin/env bash
input=$(cat)
# ... 解析并决定是否 ask ...
/usr/bin/osascript -e 'display notification "请在 Cursor 中批准终端命令" with title "Cue-Me 提醒"'
echo '{
  "permission": "ask",
  "user_message": "需要确认该命令。",
  "agent_message": "等待用户批准 shell。"
}'
```

`beforeShellExecution` 的 stdout 必须为该事件允许的 JSON 字段（见 Cursor 官方 hooks 文档与 **create-hook** skill）。

## 实现说明

- `notify.py` 会读入 stdin（避免阻塞管道），发送通知，并向 stdout 打印 `{}`，以符合 `stop` 等 hook 的 JSON 协议并降低阻断 Agent 的风险。
- `notify.sh` 将 stdin 原样交给 `notify.py`，并支持传入标题与正文覆盖默认值。
- 若某版本 Cursor 对 `stop` 的 stdout 要求不同，以 **Hooks** 输出通道报错为准；可改为只发通知、将 stdout 改为空或最小合法 JSON。

## 故障排查

- 路径：用户级 hooks 的 `command` 相对于 **`~/.cursor/`**。
- 若脚本不执行：检查 `chmod +x`、shebang、以及 `python3` 是否可用。
- 合并 `hooks.json` 时保留原有 `preToolUse`、`afterFileEdit` 等条目。
