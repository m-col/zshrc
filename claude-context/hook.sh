#!/bin/bash
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

suffix=""
[ -n "$CLAUDE_CONTEXT_ID" ] && suffix=".$CLAUDE_CONTEXT_ID"
base="$HOME/.local/share/claude"
mkdir -p "$base"
wt_file="${base}/worktree${suffix}"

if [ "$tool_name" = "ExitWorktree" ]; then
    rm -f "$wt_file"
    exit 0
fi

if [ "$tool_name" = "EnterWorktree" ]; then
    cwd=$(echo "$input" | jq -r '.cwd // empty')
    [ -n "$cwd" ] && [ -d "$cwd" ] && echo "$cwd" > "$wt_file"
    exit 0
fi

check_worktree() {
    local dir="$1"
    [ -z "$dir" ] && return
    local toplevel
    toplevel=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$toplevel" ] && [ -f "$toplevel/.git" ]; then
        echo "$toplevel" > "$wt_file"
    fi
}

if [ "$tool_name" = "Bash" ]; then
    cwd=$(echo "$input" | jq -r '.cwd // empty')
    check_worktree "$cwd"
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
[ -f "$file_path" ] || exit 0

context_file="${base}/context-files${suffix}"
tmp="${context_file}.$$"
if [ -f "$context_file" ]; then
    grep -v -F -x "$file_path" "$context_file" > "$tmp" 2>/dev/null || : > "$tmp"
else
    : > "$tmp"
fi
echo "$file_path" >> "$tmp"
tail -50 "$tmp" > "$context_file"
rm -f "$tmp"

check_worktree "$(dirname "$file_path")"

exit 0
