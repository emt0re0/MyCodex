#!/bin/bash
# ---------------------------------------------------------------------------
# Claude Code status line — minimal modern single-line layout
# Modules separated by " | "
# No icons: plain text labels only
# ---------------------------------------------------------------------------

input=$(cat)

# ---------- colour helpers (ANSI 256) ----------------------------------------
RESET="\033[0m"
CYAN="\033[38;5;80m"        # soft cyan  — model name
BLUE="\033[38;5;153m"       # soft blue  — directory
PURPLE="\033[38;5;141m"     # soft purple — git branch
GREEN="\033[38;5;114m"      # context < 50 %
YELLOW="\033[38;5;221m"     # context 50–80 %
RED="\033[38;5;203m"        # context > 80 %
ORANGE="\033[38;5;215m"     # 5h quota
GOLD="\033[38;5;179m"       # weekly quota
DIM="\033[2m"               # separator

SEP="${DIM} | ${RESET}"

# ---------- module 1: model name --------------------------------------------
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
mod_model="${CYAN}${model}${RESET}"

# ---------- module 2: directory ---------------------------------------------
cwd=$(echo "$input" | jq -r '.cwd // empty')
if [ -n "$cwd" ]; then
    mod_dir="${BLUE}${cwd}${RESET}"
else
    mod_dir=""
fi

# ---------- module 3: context usage — percentage + raw token counts ---------
# input_tokens alone excludes cache tokens; sum all token types for real usage
pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
cur=$(echo "$input" | jq -r '.context_window.current_usage // empty')

if [ -n "$pct" ] && [ -n "$ctx_size" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
    # sum input + cache_creation + cache_read tokens
    input_tok=$(echo "$input" | jq -r '
        (.context_window.current_usage.input_tokens // 0) +
        (.context_window.current_usage.cache_creation_input_tokens // 0) +
        (.context_window.current_usage.cache_read_input_tokens // 0)
    ')

    # pick colour based on percentage
    if   [ "$pct" -lt 50 ]; then CTX_COLOR="$GREEN"
    elif [ "$pct" -lt 80 ]; then CTX_COLOR="$YELLOW"
    else                          CTX_COLOR="$RED"
    fi

    # convert to k-units (1 decimal place)
    used_k=$(awk "BEGIN{v=$input_tok/1000; printf \"%.1fk\", v}")
    max_k=$(awk "BEGIN{v=$ctx_size/1000; printf \"%.0fk\", v}")
    mod_ctx="${CTX_COLOR}${pct}% (${used_k}/${max_k})${RESET}"
else
    mod_ctx=""
fi

# ---------- module 4: git branch --------------------------------------------
# Use git directly for reliability; suppress errors gracefully
git_branch=$(git -C "$(echo "$input" | jq -r '.cwd // "."')" \
    --no-optional-locks branch --show-current 2>/dev/null)
if [ -n "$git_branch" ]; then
    mod_git="${PURPLE}git: ${git_branch}${RESET}"
else
    mod_git=""
fi

# ---------- module 5: 5-hour quota remaining + reset time -------------------
five_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$five_used" ]; then
    remaining=$(echo "$five_used" | awk '{printf "%.0f", 100 - $1}')
    if [ -n "$five_resets" ]; then
        reset_time=$(date -d "@${five_resets}" +"%H:%M" 2>/dev/null)
        mod_pwr="${ORANGE}${remaining}% left (reset ${reset_time})${RESET}"
    else
        mod_pwr="${ORANGE}${remaining}% left${RESET}"
    fi
else
    mod_pwr=""
fi

# ---------- module 6: weekly quota remaining + reset date -------------------
week_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
if [ -n "$week_used" ]; then
    week_remaining=$(echo "$week_used" | awk '{printf "%.0f", 100 - $1}')
    if [ -n "$week_resets" ]; then
        reset_date=$(LC_TIME=C date -d "@${week_resets}" +"%b %-d %H:%M" 2>/dev/null)
        mod_week="${GOLD}weekly ${week_remaining}% left (reset ${reset_date})${RESET}"
    else
        mod_week="${GOLD}weekly ${week_remaining}% left${RESET}"
    fi
else
    mod_week=""
fi

# ---------- assemble line ----------------------------------------------------
line=""
for mod in "$mod_model" "$mod_dir" "$mod_ctx" "$mod_git" "$mod_pwr" "$mod_week"; do
    [ -z "$mod" ] && continue
    if [ -z "$line" ]; then
        line="$mod"
    else
        line="${line}${SEP}${mod}"
    fi
done

printf "%b\n" "$line"
