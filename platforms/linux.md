# Linux / SSH 服务器补充约定

- 连接后确认 hostname、whoami、pwd、发行版与 CPU 架构；不要因提示符相似就误操作另一台机器。
- 工具存在性用 command -v；检查登录 shell 的 PATH。CLI 在交互终端可用，不等于 SSH 启动环境可用。
- 工具优先用户目录（如 ~/.local/bin），不要假设拥有 sudo；共享服务器不修改 /etc、系统服务、其他账户或系统 Python。
- Python 使用 uv 管理；GPU 项目遵循现有 CUDA、驱动和框架要求，不擅自更换 torch/CUDA。
- 运行重任务前检查空闲 GPU、磁盘和既有进程，遵守调度器和共享机器使用规则，不终止他人进程。
- 服务器访问模型需自身具备网络连接；SSH 通畅不代表可访问外部 API。代理与桌面电脑分开确认。
- SSH 隧道默认只绑定回环地址；不把 Codex app-server 暴露到公网，不把临时隧道误报为永久网络配置。
- 桌面端远程运行需要远端 Codex CLI、可用登录状态及模型网络。分别验证 codex --version、codex login status 和实际请求。
- 私钥保留在连接发起设备，服务器只安装所需公钥；追加 authorized_keys 时保留已有条目。
- 全局规则在执行账户的 ~/.codex/AGENTS.md，不复制桌面 auth.json 或代理文件作为默认安装行为。
