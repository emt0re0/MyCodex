# MyClaudeCode

我的 Claude Code 全局配置 + 一套好用的命令行工具,一条命令装齐。
**换新机器时,把这个仓库链接丢给 Claude 就行,不用别的操作。**

- `CLAUDE.md` —— 全局约定(语言、用 uv、搜索/文件习惯、Git 习惯、网络/代理)。装完落到 `~/.claude/CLAUDE.md`,对所有项目生效。
- `statusline-command.sh` —— 自定义状态栏(模型 / 目录 / 上下文用量 / git 分支 / 额度剩余)。装完落到 `~/.claude/`。
- `install.sh` —— 无 sudo、可重复跑的安装脚本:装好下面这些工具到 `~/.local/bin`,部署 `CLAUDE.md` 和状态栏,并把 `settings.json` 的 `statusLine` 指好、`tui` 设为 `default`(关掉那个鼠标/选中自动复制的全屏模式)。

## 安装

```bash
git clone https://github.com/emt0re0/MyClaudeCode.git
bash MyClaudeCode/install.sh
```

装完往 `~/.bashrc` 末尾加这 3 行(让 zoxide 的 `z` 和 fzf 快捷键生效),然后 `source ~/.bashrc`:

```bash
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH";; esac
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
command -v fzf    >/dev/null 2>&1 && eval "$(fzf --bash)"
```

> 安装相关的细节、各平台的坑,折叠在最底部 [安装说明](#安装说明若干注意)。日常看下面的用法就够了。

---

# 工具用法速查

> 装好后,大多数工具加 `--help` 能看全部用法。下面只列最常用的。

## 🔍 搜索与跳转

### `rg` —— 在文件内容里搜(grep 的升级版,快很多)
```bash
rg "登录失败"              # 在当前目录所有文件里搜这个词
rg -i todo                # -i 忽略大小写
rg "func.*Login" -t go    # 只搜 go 文件;-t py / -t js 同理
rg foo -l                 # 只列出命中的文件名
rg foo -A 3 -B 1          # 命中行的后 3 行、前 1 行也显示
```

### `fd` —— 按文件名找文件(find 的升级版)
```bash
fd report                 # 名字含 report 的文件/目录
fd -e pdf                 # 所有 .pdf 文件
fd -e log -x rm           # 找到所有 .log 并对每个执行 rm(-x = 执行命令)
fd config ~/.config       # 在指定目录下找
```

### `fzf` —— 模糊查找,交互式选(配合管道用最爽)
```bash
fzf                       # 当前目录下边打字边过滤,回车选中
vim "$(fzf)"              # 选一个文件用 vim 打开
history | fzf             # 在历史命令里模糊找
# 装好 shell 集成后:Ctrl-R 模糊搜历史,Ctrl-T 选文件,Alt-C 跳目录
```

### `zoxide`(命令是 `z`)—— 记住你常去的目录,智能跳
```bash
z myproj                  # 跳到名字匹配且你常去的目录,不用打全路径
z dl                      # 例如跳到 ~/Downloads
zi                        # 交互式选要跳哪(配合 fzf)
# 用得越多越准;它在后台记录你 cd 过的地方
```

## 📂 看文件 / 管文件

### `bat` —— 带语法高亮和行号的 `cat`
```bash
bat config.py             # 高亮显示,自动分页
bat -n file.txt           # 只显示行号、不高亮
bat -A file               # 显示空格/制表符等不可见字符
```

### `eza` —— 更好看的 `ls`(带图标、颜色、git 状态)
```bash
eza -l                    # 长格式(类似 ls -l)
eza -la                   # 含隐藏文件
eza -l --git              # 顺带显示每个文件的 git 状态
eza --tree --level=2      # 以树状显示两层
# 可在 ~/.bashrc 里 alias ls='eza' 替换默认 ls
```

### `yazi` —— 终端里的可视化文件管理器(像图形界面那样浏览)
```bash
yazi                      # 打开;方向键移动,回车进目录/打开文件,q 退出
# 常用键:空格 选中, y 复制, x 剪切, p 粘贴, d 删除, / 搜索
```

### `tree` —— 把目录画成树
```bash
tree -L 2                 # 只显示两层
tree -d                   # 只看目录
```

## 📊 数据与系统

### `jq` —— 处理/查询 JSON
```bash
cat data.json | jq .              # 格式化美化输出
jq '.name' data.json              # 取某个字段
jq '.items[].id' data.json        # 取数组里每个元素的 id
curl -s api.xxx/users | jq '.[0]' # 配合接口返回用
```

### `dust` —— 看哪个目录/文件占空间(`du` 的可视化版)
```bash
dust                      # 当前目录,按占用从大到小、带条形图
dust -d 2                 # 只往下看两层
dust ~/Downloads          # 看指定目录
```

### `btop` —— 资源监控(CPU/内存/进程,像任务管理器)
```bash
btop                      # 打开;鼠标可点,q 退出。看哪个进程吃 CPU/内存就用它
```

## 🛠 开发

### `gh` —— GitHub 命令行(在终端里管 PR / issue / 仓库)
```bash
gh auth login             # 首次:登录(浏览器授权,一次就好)
gh repo clone owner/name  # clone 仓库
gh pr create              # 基于当前分支建 PR
gh pr list / gh issue list
gh pr checkout 123        # 把别人的 PR #123 拉到本地
```

### `uv` —— Python 的项目/依赖/运行(替代 pip + venv + conda)
```bash
uv init myproj && cd myproj   # 新建项目
uv add requests               # 加依赖(写进 pyproject.toml)
uv run python app.py          # 在项目环境里跑
uv run --with numpy python x.py  # 临时带个包跑一次,不污染项目
uv sync                       # 进别人项目时按 lock 文件装齐依赖
uvx ruff check                # 不安装、直接跑某个工具
```

### `ruff` —— Python 代码检查 + 格式化(超快)
```bash
ruff check .              # 检查问题
ruff check . --fix        # 能自动修的直接修
ruff format .             # 格式化(类似 black)
```

### `node` / `npm` —— JavaScript 运行时
```bash
node app.js               # 跑 js
npm install               # 装项目依赖
npm run dev               # 跑 package.json 里的脚本
```

## 🎬 媒体与文档

### `ffmpeg` —— 音视频转换/剪切/压缩(万能)
```bash
ffmpeg -i in.mov out.mp4                       # 转格式
ffmpeg -i in.mp4 -ss 00:00:10 -t 30 out.mp4    # 从第10秒起截30秒
ffmpeg -i in.mp4 audio.mp3                      # 抽音轨
ffmpeg -i in.mp4 -vf scale=1280:-1 out.mp4      # 缩放到宽1280
```

### `magick` —— 图片处理(转换/缩放/裁剪,ImageMagick)
```bash
magick in.png out.jpg                  # 转格式
magick in.png -resize 50% out.png      # 缩小一半
magick in.png -resize 800x600 out.png  # 指定尺寸
magick *.png out.pdf                   # 多张图合成一个 pdf
```

### `pdftotext` / poppler —— 从 PDF 抽内容
```bash
pdftotext paper.pdf            # 导出 paper.txt
pdftotext -layout paper.pdf -  # 保留排版,直接打到屏幕
pdfimages -all paper.pdf img   # 把里面的图都导出来
pdftoppm -png -r 150 p.pdf pg  # 每页转成 png 图片
```

### `pandoc` —— 文档格式互转(md / docx / html / pdf …)
```bash
pandoc in.md -o out.docx       # markdown 转 word
pandoc in.md -o out.html       # 转网页
pandoc in.docx -o out.md       # word 转 markdown
```

### `yt-dlp` —— 下载网上的视频/音频
```bash
yt-dlp "<链接>"                    # 下视频(最佳画质)
yt-dlp -x --audio-format mp3 "<链接>"  # 只要音频转 mp3
yt-dlp -F "<链接>"                 # 列出可选清晰度/格式
```

---

# 一句话各干嘛(健忘时瞄一眼)

| 工具 | 干嘛的 | 旧的对应 |
|------|--------|----------|
| `rg` | 搜文件内容 | grep |
| `fd` | 按名字找文件 | find |
| `fzf` | 模糊交互查找 | — |
| `z` (zoxide) | 智能跳目录 | cd |
| `bat` | 带高亮看文件 | cat |
| `eza` | 更好看的列目录 | ls |
| `yazi` | 可视化文件管理器 | — |
| `tree` | 目录树 | — |
| `jq` | 处理 JSON | — |
| `dust` | 看磁盘占用 | du |
| `btop` | 资源监控 | top |
| `gh` | GitHub 命令行 | — |
| `uv` | Python 项目/依赖 | pip+venv |
| `ruff` | Python 检查/格式化 | flake8+black |
| `ffmpeg` | 音视频处理 | — |
| `magick` | 图片处理 | — |
| `pdftotext` | PDF 抽文字 | — |
| `pandoc` | 文档格式互转 | — |
| `yt-dlp` | 下载视频 | — |

---

# 安装说明(若干注意)

<details>
<summary>展开:安装机制 / 踩过的坑</summary>

- **全部无 sudo,装进 `~/.local/bin`**;脚本幂等,已装的会跳过(`FORCE=1 bash install.sh` 可强制重装)。
- 安装来源:`ruff`/`yt-dlp` 用 `uv tool install`;`fd bat eza dust gh fzf zoxide pandoc btop yazi` 取 GitHub release 二进制;`node` 取 nodejs.org 最新 LTS;`magick` 用 ImageMagick 官方 AppImage。
- `rg uv` 通常已自带;`git tree jq ffmpeg poppler` 一般发行版已有,缺则 `sudo apt install -y git tree jq ffmpeg poppler-utils`。

实测在 **Ubuntu 22.04 + 无 sudo** 环境,记下来的坑:

1. glibc 2.35:`yazi` 的 gnu 版需要 glibc 2.39,会报 `GLIBC_2.39 not found` → 改用 **musl** 版;`btop` 也用 musl。`fd/bat/eza/dust` 的 gnu 版没问题。
2. `curl | sh` 会被 Claude Code 权限分类器拦(远程脚本执行)→ zoxide 改成直接下 release 包。
3. apt 的 ImageMagick 是 v6、**没有 `magick` 命令**;v7 的 `magick` 用官方 GitHub release 的 AppImage(旧站点路径已失效)。有 FUSE 直接跑,没 FUSE 就 `--appimage-extract` 解包后用 `AppRun` 包一层。
4. 改 `~/.bashrc` 会被权限分类器拦 → shell 集成那 3 行需手动加。

</details>
