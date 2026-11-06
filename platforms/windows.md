# Windows 补充约定

- 使用 PowerShell，命令存在性用 Get-Command，读取用 Get-Content；路径含空格时正确引用，文件操作优先 -LiteralPath。
- 列目录和查找可回退 Get-ChildItem；不要将 cmd、Bash 和 PowerShell 的转义规则混在一条命令里。
- UTF-8 文本输出使用显式编码；脚本与配置注意 BOM、CRLF 和外部程序兼容性。Shell 脚本保持 LF。
- Python 依赖仍由 uv 管理；不要依赖 Microsoft Store 的 python 占位命令，不假定 python3 存在。
- 原生工具可通过 winget 或官方发行包安装到用户目录；先查软件包身份、版本及安装范围。
- 本机网络先检查代理进程、端口和系统代理；只在确认协议后配置 HTTP_PROXY / HTTPS_PROXY / ALL_PROXY。
- SSH 配置在用户目录 .ssh/config；密钥每台设备独立，已存在的私钥不覆盖。Windows 的盘符路径不能当作 Linux 路径。
- 桌面端 SSH 项目的文件和命令实际在远端执行；部署规则到远端账户，不能只改 Windows 全局文件。
- 修改前检查文件占用；后台程序不要弹出多余窗口。不要强行结束正在保存数据的应用。
