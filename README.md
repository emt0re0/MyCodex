# MyCodex

我的 Codex 全局配置与三设备使用指南。由 MyClaudeCode 迁移，保留 uv、搜索、工具选择、Git 和网络排查习惯，并分别适配 Windows、macOS、Linux/SSH。

## 目录与生效方式

| 文件 | 用途 |
|---|---|
| AGENTS.md | 所有设备共同遵循的全局 prompt |
| platforms/windows.md | PowerShell、Windows 路径、编码、代理与 SSH |
| platforms/macos.md | zsh、Homebrew、BSD 工具、GUI 环境与钥匙串 |
| platforms/linux.md | SSH、共享服务器、GPU、用户目录工具与远程网络 |
| install.ps1 / install.sh | 将通用规则和一个平台规则合并安装 |
| docs/SETUP.md | 配置位置、更新、备份和回滚 |
| docs/TOOLS.md | 工具用途及按平台安装原则 |
| legacy/ | 原 Claude 配置归档，不由安装器执行 |

Codex 最终读取执行设备用户目录中的 AGENTS.md。平台文件不会凭文件名自动加载；本仓库安装脚本负责合并。不要一次装入三个平台的规则。

## Windows

克隆本仓库后，在 PowerShell 中进入仓库目录：
```powershell
git clone https://github.com/emt0re0/MyCodex.git
cd MyCodex
./install.ps1 -WhatIf
./install.ps1
```
默认安装到用户目录 .codex/AGENTS.md；支持 CODEX_HOME 或显式 -CodexHome。只修改该目标，不改变机器的执行策略。

## macOS

```sh
git clone https://github.com/emt0re0/MyCodex.git
cd MyCodex
sh install.sh --platform macos --dry-run
sh install.sh --platform macos
```

## Linux / SSH 服务器

在目标 Linux 账户中执行：
```sh
git clone https://github.com/emt0re0/MyCodex.git
cd MyCodex
sh install.sh --platform linux --dry-run
sh install.sh --platform linux
```
macOS/Linux 不传 --platform 时按 uname 自动检测。安装规则不要求 sudo。没有 git 时可从 GitHub 下载仓库压缩包再执行安装脚本。

## 更新和验证

保持配置仓库干净后 git pull --ff-only，再运行对应安装器。修改本地规则前先回写仓库，否则重新安装会覆盖本地手改内容（会先备份）。
安装器验证写入内容；新开 Codex 聊天并询问当前规则，可进一步确认加载。Mac 配置应在真实 Mac 上验证；跨平台预演不代表已验证桌面端行为。

## 这套配置不包含什么

安装器只安装 prompt，不安装 Codex CLI、开发工具、插件、登录凭据、代理和 SSH 密钥，也不修改模型或权限设置。prompt 是工作约定，不是安全沙箱或软件配置的替代品。
同账号不会自动复制这些文件；各设备更新仓库并重新安装即可。项目专用约定可写项目 AGENTS.md，本仓库不加入简历、求职或其他项目私人信息。

Windows 桌面端通过 SSH 使用 Linux 时，执行发生在 Linux，远端需单独安装 CLI、登录账号并能访问模型服务。参见 [官方远程说明](https://learn.chatgpt.com/docs/remote-connections)。

## Claude 迁移

原 CLAUDE.md 与状态栏在 legacy/ 留档。Claude statusLine、settings.json 和 Ubuntu 工具批量安装脚本不会直接作为 Codex Desktop 配置使用。保留旧文件便于对照，实际维护入口是通用规则和三个平台文件。
