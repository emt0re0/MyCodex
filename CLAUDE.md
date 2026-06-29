# CLAUDE.md

本机的基础工具约定。项目特有的规则写在各仓库自己的 `CLAUDE.md`,其优先级高于本文件。

## 语言
- 默认用中文回复。
- 但任务本身是英文语境时用英文 —— 例如写/改英文 LaTeX 论文、英文学术写作、英文文档。
- 代码、命令、commit message、变量/函数命名等始终用英文。

## Python —— 用 uv
- 用 `uv`,不要用 pip 或 conda。
- 加依赖 `uv add <pkg>`;移除 `uv remove <pkg>`;运行 `uv run python ...` 或 `uv run <script>`。
- 进入已有项目时用 `uv sync` 按 lockfile 安装/同步依赖。
- 三种环境用法别搞混:
  - 长期依赖 → `uv add <pkg>`(写进 pyproject.toml / uv.lock)。
  - 临时跑一次、不想污染项目 → `uv run --with <pkg> ...`,例:`uv run --with numpy --with torch python x.py`。它只为这次命令拼一个临时环境,不改 lockfile、不留痕。试用某个包或跑一次性脚本时用它;确定要长期用再 `uv add`。
  - 全局独立 CLI 工具 → `uv tool install <tool>`(只跑一次用 `uvx <tool>`),不要写进项目依赖。
- 单文件脚本用 PEP 723 内联元数据:`uv run script.py`、`uv add <pkg> --script script.py`。
- 每个项目用自己的 `.venv`(`uv init` / `uv venv`)。绝不往全局 Python 装依赖。
- 改完 Python 代码顺手跑 `ruff check` / `ruff format`(若项目使用 ruff)。

## 搜索与文件操作
- 搜文件内容用 `rg`(ripgrep),按文件名找用 `fd`。两者都比 grep/find 快;找不到时再退回替代方案。
- 相互独立的工具调用尽量并行,尤其是多个文件读取。
- 判断命令是否存在用 `command -v <cmd>`。
- 一次性验证优先用 `python3 -c "..."`(或 `uv run python -c`)和 here-doc,别为此乱建临时文件。
- 不臆造文件路径、函数名或 API。不确定就用 `rg`/`fd` 查证后再写。

## 可用的 CLI 工具(相关时优先使用)
- 搜索/导航:`rg`(内容)、`fd`(文件名)、`fzf`(模糊查找)、`zoxide`(`z`,智能 cd)
- 文件/查看:`bat`(带高亮的 cat)、`eza`(现代 ls)、`yazi`(终端文件管理器)、`tree`
- 数据/监控:`jq`(JSON)、`dust`(磁盘占用)、`btop`(资源监控)
- 版本管理:`git`、`gh`(GitHub CLI)
- JS 运行时:`node` / `npm`
- 媒体/文档:`ffmpeg`、`poppler`(pdftotext / pdfimages / pdftoppm)、`imagemagick`(`magick`)、`pandoc`、`yt-dlp`

## 工具缺失时(如何选择与安装)
- 默认用最好的工具(`rg`/`fd`/`uv` 等),不要因为「可能没装」就预先退回 grep/find。先用 `command -v <cmd>` 确认。
- 缺的是 Python 工具:直接用 `uvx <tool>` 或 `uv run --with <pkg> ...` 零安装运行,隔离且安全,不需要询问。
- 安装的判断标准看「破坏性」而非「要不要 sudo」:
  - 优先无 sudo、装家目录的方式:`uv tool install`、GitHub release 二进制丢进 `~/.local/bin`、`npm i -g`(用户级)。这类隔离、可回滚,直接做。
  - 装标准软件包(`sudo dnf install` / `apt install` 官方源的干净包)风险很低,可加且可回滚,**可以直接 sudo 装**;装多个或不常见的包时,顺带说一句装了什么。
  - 真正要先说明并等确认的是**破坏性 / 影响他人**的操作:删或覆盖系统文件、改 `/etc` 等全局配置、动别人家目录、`rm -rf`、改系统服务、改属主/权限。这些无论要不要 sudo 都先讲清楚。
- 在共享服务器上的底线:可加性操作放手做,但绝不动别人的数据、绝不改会影响其他用户的系统状态。
- 退而求其次用了替代方案时,明确告诉我用的是什么、为什么。

## Git
- 改动前后给出 diff。不要自动 commit 或 push —— 等确认。
- 不要在未事先说明的情况下执行破坏性命令(`git reset --hard`、`rm -rf`、强制覆盖)。

## 网络 / 代理
- **每台机器网络不一样,先探测别假设**:有的直连外网,有的要走代理。先看 env 有没有 `http_proxy` / `https_proxy` / `ALL_PROXY` 或测一下连通,再决定怎么连。
- 直连外网超时、env 又没代理变量,多半是需要本地代理(常见 `127.0.0.1:<端口>` 的 clash/v2ray):查本机有没有在跑,把端口写进 `http(s)_proxy` 再试。
