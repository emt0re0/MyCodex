# macOS 补充约定

- 先确认 shell（常见 zsh）与架构（Apple Silicon / Intel），不要默认与 Linux 相同。
- 工具存在性用 command -v；优先已有工具。使用 Homebrew 前检查 brew 是否存在以及实际 prefix，不写死 /opt/homebrew 或 /usr/local。
- BSD 与 GNU 工具参数不同，尤其 sed -i、date、stat、readlink；检查帮助或选择可移植实现。
- 路径正确引用，注意文件系统可能不区分大小写；不要只靠大小写判断是否同一个文件。
- Python 使用 uv 项目环境，不改系统 Python，不向 Homebrew Python 全局安装项目依赖。
- GUI 启动程序可能不继承终端环境变量；验证 Codex 实际启动环境，不能只看终端 env。
- 代理端口和协议独立探测，不复制 Windows 的 .env。修改 shell 启动文件前备份，避免重复添加初始化代码。
- SSH 使用本机独立密钥，可结合系统 ssh-agent/钥匙串；不要把其他电脑的私钥提交或复制进配置仓库。
- 全局规则默认 ~/.codex/AGENTS.md，项目规则放项目目录；配置更新后用新聊天确认加载。
