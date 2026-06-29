#!/usr/bin/env bash
# MyClaudeCode bootstrap installer.
#
# 在一台新机器上配置 Claude Code 的全局约定 + 常用 CLI 工具。
# 设计目标:无 sudo、全部装进 ~/.local(隔离、可回滚、可重复运行)。
#
#   curl -fsSL https://raw.githubusercontent.com/emt0re0/MyClaudeCode/main/install.sh | bash
# 或 clone 后:
#   bash install.sh
#
# 幂等:已安装的工具会跳过(除非 FORCE=1)。

set -uo pipefail

BIN="$HOME/.local/bin"
LIB="$HOME/.local/lib"
mkdir -p "$BIN" "$LIB"
export PATH="$BIN:$PATH"

FORCE="${FORCE:-0}"
ok()   { printf '\033[32mOK\033[0m   %s\n' "$*"; }
skip() { printf '\033[33mSKIP\033[0m %s\n' "$*"; }
warn() { printf '\033[31mWARN\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
need() { [ "$FORCE" = 1 ] || ! have "$1"; }  # true 表示需要安装

latest_tag() { # latest_tag owner/repo -> vX.Y.Z (跟随 /releases/latest 重定向)
  curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest" | sed 's#.*/tag/##'
}

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT; cd "$TMP"

# 从 GitHub release 下载一个压缩包并把其中某个二进制装进 ~/.local/bin
# 用法: gh_bin <名字> <owner/repo> <asset模板> <包内二进制路径模板>
# 模板里 {tag}=vX.Y.Z, {ver}=X.Y.Z
gh_bin() {
  local name="$1" repo="$2" at="$3" bt="$4"
  need "$name" || { skip "$name (已存在)"; return 0; }
  local tag ver asset binp url d
  tag="$(latest_tag "$repo")"; ver="${tag#v}"
  asset="$(echo "$at" | sed "s/{tag}/$tag/g; s/{ver}/$ver/g")"
  binp="$(echo "$bt" | sed "s/{tag}/$tag/g; s/{ver}/$ver/g")"
  url="https://github.com/$repo/releases/download/$tag/$asset"
  d="$TMP/$name"; rm -rf "$d"; mkdir -p "$d"; ( cd "$d"
    curl -fsSL "$url" -o "$asset" || { warn "$name 下载失败 $url"; exit 1; }
    case "$asset" in
      *.tar.gz|*.tgz)  tar xzf "$asset" ;;
      *.tar.bz2|*.tbz) tar xjf "$asset" ;;
      *.tar.xz)        tar xJf "$asset" ;;
      *.zip)           unzip -qo "$asset" ;;
    esac
    [ -f "$binp" ] || { warn "$name 解包后找不到 $binp"; exit 1; }
    install -m755 "$binp" "$BIN/$name"
  ) && ok "$name -> $("$BIN/$name" --version 2>&1 | head -1)"
}

echo "==> 1/4 安装全局 CLAUDE.md"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" && pwd)"
if [ -f "$SRC_DIR/CLAUDE.md" ]; then
  mkdir -p "$HOME/.claude"
  cp "$SRC_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md" && ok "~/.claude/CLAUDE.md"
else
  # 通过 curl|bash 运行时本地没有文件,从 raw 拉取
  mkdir -p "$HOME/.claude"
  curl -fsSL https://raw.githubusercontent.com/emt0re0/MyClaudeCode/main/CLAUDE.md \
    -o "$HOME/.claude/CLAUDE.md" && ok "~/.claude/CLAUDE.md (从 raw 拉取)"
fi

echo "==> 2/4 Python 工具 (uv)"
if have uv; then
  for t in ruff yt-dlp; do
    need "$t" && { uv tool install "$t" >/dev/null 2>&1 && ok "$t (uv tool)"; } || skip "$t"
  done
else
  warn "未检测到 uv,跳过 ruff / yt-dlp。先装 uv: https://docs.astral.sh/uv/"
fi

echo "==> 3/4 GitHub release 二进制"
# 注意:Ubuntu 22.04 的 glibc 是 2.35。fd/bat/eza/dust 的 gnu 版兼容;
# 但部分新项目(如 yazi)的 gnu 版需要 glibc 2.39 —— 这些一律用 musl 版。
gh_bin fd   sharkdp/fd        "fd-{tag}-x86_64-unknown-linux-gnu.tar.gz"   "fd-{tag}-x86_64-unknown-linux-gnu/fd"
gh_bin bat  sharkdp/bat       "bat-{tag}-x86_64-unknown-linux-gnu.tar.gz"  "bat-{tag}-x86_64-unknown-linux-gnu/bat"
gh_bin eza  eza-community/eza "eza_x86_64-unknown-linux-gnu.tar.gz"        "eza"
gh_bin dust bootandy/dust     "dust-{tag}-x86_64-unknown-linux-gnu.tar.gz" "dust-{tag}-x86_64-unknown-linux-gnu/dust"
gh_bin gh   cli/cli           "gh_{ver}_linux_amd64.tar.gz"                "gh_{ver}_linux_amd64/bin/gh"
gh_bin fzf  junegunn/fzf      "fzf-{ver}-linux_amd64.tar.gz"               "fzf"
gh_bin btop aristocratos/btop "btop-x86_64-unknown-linux-musl.tar.gz"      "btop/bin/btop"
gh_bin zoxide ajeetdsouza/zoxide "zoxide-{ver}-x86_64-unknown-linux-musl.tar.gz" "zoxide"
gh_bin pandoc jgm/pandoc      "pandoc-{ver}-linux-amd64.tar.gz"            "pandoc-{ver}/bin/pandoc"
# yazi:gnu 版需 glibc 2.39,用 musl 版;同时装伴随的 ya
if need yazi; then
  tag="$(latest_tag sxyazi/yazi)"; d="$TMP/yazi"; mkdir -p "$d"; ( cd "$d"
    curl -fsSL "https://github.com/sxyazi/yazi/releases/download/$tag/yazi-x86_64-unknown-linux-musl.zip" -o y.zip \
      && unzip -qo y.zip \
      && install -m755 yazi-x86_64-unknown-linux-musl/yazi "$BIN/yazi" \
      && install -m755 yazi-x86_64-unknown-linux-musl/ya   "$BIN/ya"
  ) && ok "yazi -> $(yazi --version 2>&1 | head -1)" || warn "yazi 安装失败"
else skip yazi; fi

echo "==> 4/4 Node.js (LTS) 与 ImageMagick"
# Node:从 nodejs.org 取最新 LTS,解包到 ~/.local/lib/nodejs,软链 node/npm/npx
if need node; then
  ver="$(curl -fsSL https://nodejs.org/dist/index.json | jq -r '[.[]|select(.lts!=false)][0].version')"
  ( curl -fsSL "https://nodejs.org/dist/$ver/node-$ver-linux-x64.tar.xz" -o "$TMP/node.tar.xz" \
    && mkdir -p "$LIB/nodejs" && tar xJf "$TMP/node.tar.xz" -C "$LIB/nodejs" \
    && nd="$LIB/nodejs/node-$ver-linux-x64" \
    && ln -sf "$nd/bin/node" "$BIN/node" && ln -sf "$nd/bin/npm" "$BIN/npm" && ln -sf "$nd/bin/npx" "$BIN/npx" \
  ) && ok "node $(node -v) / npm $(npm -v)" || warn "node 安装失败"
else skip node; fi

# ImageMagick:apt 的是 v6(无 magick 命令);用官方 AppImage 拿到 v7 的 magick。
# FUSE 可用则直接放 AppImage;否则 --appimage-extract 后用 AppRun 包一层。
if need magick; then
  tag="$(latest_tag ImageMagick/ImageMagick)"
  if curl -fsSL "https://github.com/ImageMagick/ImageMagick/releases/download/$tag/ImageMagick-$tag-gcc-x86_64.AppImage" -o "$TMP/m.AppImage"; then
    chmod +x "$TMP/m.AppImage"
    if "$TMP/m.AppImage" --version >/dev/null 2>&1; then
      install -m755 "$TMP/m.AppImage" "$BIN/magick" && ok "magick (AppImage 直跑) -> $(magick --version 2>&1|head -1)"
    elif ( cd "$TMP" && "$TMP/m.AppImage" --appimage-extract >/dev/null 2>&1 ); then
      rm -rf "$LIB/magick"; mv "$TMP/squashfs-root" "$LIB/magick"
      printf '#!/bin/sh\nexec "%s/AppRun" "$@"\n' "$LIB/magick" > "$BIN/magick"; chmod +x "$BIN/magick"
      ok "magick (解包+AppRun) -> $(magick --version 2>&1|head -1)"
    else warn "magick 既不能直跑也不能解包"; fi
  else warn "magick AppImage 下载失败"; fi
else skip magick; fi

cat <<'NOTE'

—— 完成 ——
所有二进制在 ~/.local/bin(需在 PATH 中)。

可选:把下面几行加进 ~/.bashrc 让 zoxide 的 z、fzf 快捷键生效
(本脚本不会自动改你的 shell 配置):

  case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH";; esac
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
  command -v fzf    >/dev/null 2>&1 && eval "$(fzf --bash)"

依赖发行版自带(通常已有):git, tree, jq, ffmpeg, poppler-utils(pdftotext 等)。
缺的话:sudo apt install -y git tree jq ffmpeg poppler-utils
NOTE
