# QuotaHalo

![macOS](https://img.shields.io/badge/macOS-13%2B-black)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-blue)
![Codex](https://img.shields.io/badge/Codex-usage%20widget-00d4ff)

**QuotaHalo 是一个 macOS 透明玻璃桌面小组件，用来一眼查看 Codex 用量余量。**

它会显示 **每 5 小时** 和 **每周** 两个 Codex 配额窗口，包括余量百分比和重置时间；不需要用户提供 API key，也不会保存 OpenAI token。

[下载最新版 QuotaHalo.app.zip](https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip) · [English README](README.md) · [认证说明](docs/AUTHENTICATION.md)

关键词：`Codex usage`、`Codex quota`、`macOS widget`、`desktop widget`、`glass widget`、`ChatGPT Codex`、`OpenAI Codex`

## 预览

| English | 中文 |
| --- | --- |
| ![English preview](assets/preview-en.png) | ![Chinese preview](assets/preview-zh-Hans.png) |

## 安装

1. 下载最新版 [`QuotaHalo.app.zip`](https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip)。
2. 解压。
3. 把 `QuotaHalo.app` 拖进 `Applications`。
4. 双击 `QuotaHalo.app`。

如果 macOS 因为未签名阻止首次打开，右键 app 选择 `Open`。

如果 macOS 提示 app 已损坏，通常是下载的构建没有完成正式签名和 Apple 公证。见 [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md)。

请使用上面的稳定下载地址，不要分享 `untagged-*` 这种 GitHub 临时 release asset 链接。

## 登录

QuotaHalo 使用你本机的 Codex 登录状态，不需要 API key。

1. 打开 QuotaHalo 菜单栏图标。
2. 选择 `Setup...`。
3. 点击 `Open Codex App` 或 `Start Codex Login`。
4. 完成官方 Codex 登录流程。
5. 点击 `Refresh Quota`。

`Start Codex Login` 可能会打开一个小 Terminal 窗口，替你运行官方 `codex login`。你不需要手动输入命令。

## 它会显示什么

- Codex 每 5 小时余量。
- 每 5 小时窗口重置时间。
- Codex 每周余量。
- 每周窗口重置时间。
- 停留在 macOS 桌面的透明玻璃小组件。
- English 和中文 UI。

## 隐私

QuotaHalo 刻意保持很小：

- 不索要 OpenAI API key。
- 不读取、不保存、不打印、不上传 OpenAI/Codex 凭据。
- 只启动本机 `codex app-server --stdio`，通过 `account/rateLimits/read` 读取配额快照。

完整认证模型见 [docs/AUTHENTICATION.md](docs/AUTHENTICATION.md)。

> 非官方项目，与 OpenAI 无隶属关系。

## 更多文档

- [不用命令的用户流程](docs/NO_TERMINAL.md)
- [认证说明](docs/AUTHENTICATION.md)
- [发布、签名和公证](docs/DISTRIBUTION.md)
- [手动 JSON 回退](docs/MANUAL_JSON.md)
- [开发者指南](docs/DEVELOPMENT.md)
- [图标说明](docs/ICON_GUIDE.md)
- [仓库检索优化清单](docs/REPO_DISCOVERY.md)

## 要求

- macOS 13 或更高。
- 本机已安装 Codex。
- Codex 已使用 ChatGPT 登录。

## 语言

默认语言：English。

从菜单栏选择：

```text
Language -> English / 中文
```

## 许可证

MIT。见 [LICENSE](LICENSE)。
