# 工具选择与速查

工具是按需选用，不是安装器承诺已经存在。Windows 用 Get-Command，macOS/Linux 用 command -v 检查。

| 场景 | 工具 | 示例 |
|---|---|---|
| 内容搜索 | rg | rg -n 'pattern' src |
| 文件搜索 | rg / fd | rg --files；fd report |
| Python 依赖 | uv | uv sync；uv add requests |
| 临时 Python 包 | uv | uv run --with numpy python script.py |
| 临时 CLI | uvx | uvx ruff check . |
| GitHub | gh | gh auth status；gh pr list |
| JSON | jq | jq '.name' file.json |
| 文件预览 | bat / eza / tree | bat README.md；tree -L 2 |
| 导航 | fzf / zoxide / yazi | fzf；z project；yazi |
| 资源 | dust / btop | dust；btop |
| 文档 | poppler / pandoc | pdftotext -layout paper.pdf - |
| 图片 | ImageMagick | magick input.png output.jpg |
| 媒体 | ffmpeg / yt-dlp | ffmpeg -i input.mp4 output.mp3 |

## 平台安装原则

- Windows：优先已有工具、可信 winget 软件包或官方发行包；核对用户安装范围和 PATH。PowerShell 不执行 Ubuntu 的 apt 命令。
- macOS：Homebrew 已安装时可用 brew；先确认架构和 prefix，避免混装 Intel 与 ARM 二进制。
- Linux：优先用户目录安装，Python 工具可用 uv tool；共享服务器不擅自 sudo 或修改系统环境。
- 各平台先确认依赖和许可；网络安装失败先诊断代理。保留失败信息，不静默换未经核实的镜像。

## Git 工作流

先 git status --short 与 git diff，修改后复核差异和必要检查。用户明确要求同步仓库时才 commit/push；普通文件修改不自动发布。push 遇到远端更新先获取和比较，不强推覆盖。
