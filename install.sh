#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
platform=
dry_run=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --platform) [ "$#" -ge 2 ] || { echo 'Missing platform' >&2; exit 2; }; platform=$2; shift ;;
    --dry-run) dry_run=1 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done
if [ -z "$platform" ]; then
  case "$(uname -s)" in
    Darwin) platform=macos ;;
    Linux) platform=linux ;;
    *) echo 'Use install.ps1 on Windows or specify --platform' >&2; exit 2 ;;
  esac
fi
case "$platform" in windows|macos|linux) ;; *) echo 'Invalid platform' >&2; exit 2 ;; esac
dest=${CODEX_HOME:-"$HOME/.codex"}
if [ "$dry_run" -eq 1 ]; then
  printf 'Install common + %s -> %s/AGENTS.md (with backup)\n' "$platform" "$dest"
  exit 0
fi
mkdir -p "$dest"
tmp=$(mktemp "$dest/.AGENTS.install.XXXXXX")
trap 'rm -f "$tmp"' EXIT HUP INT TERM
cat "$root/AGENTS.md" > "$tmp"
printf '\n' >> "$tmp"
cat "$root/platforms/$platform.md" >> "$tmp"
if [ -f "$dest/AGENTS.md" ]; then
  backup=$(mktemp "$dest/AGENTS.md.backup.XXXXXX")
  cp "$dest/AGENTS.md" "$backup"
fi
cp "$tmp" "$dest/AGENTS.md"
cmp "$tmp" "$dest/AGENTS.md"
printf 'Installed common + %s: %s/AGENTS.md\n' "$platform" "$dest"
