cw() {
    local suffix=""
    [[ -n "$CLAUDE_CONTEXT_ID" ]] && suffix=".$CLAUDE_CONTEXT_ID"
    local wt_file="$HOME/.local/share/claude/worktree${suffix}"
    [[ -f "$wt_file" ]] || return 1
    local wt
    wt=$(<"$wt_file")
    [[ -d "$wt" ]] || return 1
    cd "$wt"
}

_zsh_autosuggest_strategy_claude() {
    emulate -L zsh
    setopt EXTENDED_GLOB

    typeset -g suggestion
    local suffix=""
    [[ -n "$CLAUDE_CONTEXT_ID" ]] && suffix=".$CLAUDE_CONTEXT_ID"
    local context_file="$HOME/.local/share/claude/context-files${suffix}"
    [[ -f "$context_file" ]] || return

    local buffer="$1"
    local cmd partial

    [[ "$buffer" =~ '^(v|vi|vim|nvim)( +(.*))?$' ]] || return
    cmd="${match[1]}"
    partial="${match[3]}"

    local -a files
    files=("${(@f)$(< "$context_file")}")
    (( ${#files} )) || return

    local f rel

    if [[ -n "$partial" ]]; then
        for f in "${(@Oa)files}"; do
            [[ -f "$f" ]] || continue
            rel="${f#$PWD/}"
            [[ "$rel" == ${partial}* ]] && { suggestion="$cmd $rel"; return }
        done
        for f in "${(@Oa)files}"; do
            [[ -f "$f" ]] || continue
            rel="${f#$PWD/}"
            [[ "$rel" == *${partial}* ]] && { suggestion="$cmd $rel"; return }
        done
    else
        for f in "${(@Oa)files}"; do
            [[ -f "$f" ]] || continue
            rel="${f#$PWD/}"
            suggestion="$cmd $rel"
            return
        done
    fi
}
