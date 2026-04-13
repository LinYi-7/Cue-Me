# Cue-Me

在 macOS 上通过 **Cursor Hooks** 在 Agent 结束、子任务结束或需要你在终端/MCP 里点批准时，弹出 **系统通知**（默认标题「Cue-Me 提醒」、中文正文）。通知通过 **terminal-notifier** 以 Cursor 的 Bundle ID 发送，与 **系统设置 → 通知 → Cursor** 一致。

## 适用环境

- macOS
- Cursor（用户级 hooks：`~/.cursor/hooks.json`）

## 别人怎么用

### 1. 拿到本仓库

```bash
git clone https://github.com/<你的用户名>/<仓库名>.git
cd <仓库名>
```

### 2. 安装脚本到本机

在**仓库根目录**执行：

```bash
bash .cursor/skills/cue-me/scripts/install-user-hooks.sh
```

脚本会：

- 将 `notify.py`、`notify.sh`、`notify-stop.sh` 等复制到 `~/.cursor/hooks/`
- 下载 **terminal-notifier.app**（用于走 Cursor 通知渠道）
- 若不存在 `~/.cursor/hooks.json` 会创建示例；**若已存在则不会覆盖**，需自行合并示例里的 `stop` 等配置

### 3. 合并 `hooks.json`（若已有自定义 hooks）

参考仓库内：

- [`.cursor/skills/cue-me/examples/hooks.user.json`](.cursor/skills/cue-me/examples/hooks.user.json)

把 `stop`、`subagentStop` 等条目**合并进** `~/.cursor/hooks.json`，勿删掉原有 hook。

### 4. 作为 Cursor Skill 使用

将本目录中的 skill 拷到 Cursor 技能目录之一即可：

- 个人全局：`~/.cursor/skills/cue-me/`（把整个 `cue-me` 文件夹复制过去）
- 或仅在某项目内：`<项目>/.cursor/skills/cue-me/`

详细说明见 skill 内文档：

- [`.cursor/skills/cue-me/SKILL.md`](.cursor/skills/cue-me/SKILL.md)

## 自检

```bash
echo '{}' | ~/.cursor/hooks/notify-stop.sh
```

若系统通知出现且标题为「Cue-Me 提醒」，说明脚本侧正常。

## 许可

仓库作者可自行补充 LICENSE；使用前请自行评估是否满足你的环境与安全策略。
