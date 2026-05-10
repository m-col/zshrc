#!/usr/bin/env bash

title="$@"

# prompt for title interactively if not passed as an arg (used by zellij keybinding)
if [[ -z "$title" ]]; then
    printf "Title: "
    read title
    [[ -z "$title" ]] && exit 1
fi

ctx_id=$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -c1-8)

#exec alacritty msg create-window \
#    --working-directory ~/git \
#    --command /bin/zsh -c \
#	'/opt/homebrew/bin/tmux new-session -s "'"$title"'" -e CLAUDE_CONTEXT_ID='"$ctx_id"' \; split-window -h "/opt/homebrew/bin/claude --dangerously-skip-permissions; zsh" \; select-pane -t 1'

# Rio can't launch in new tab
#exec rio \
#    --working-dir ~/git \
#    --title-placeholder "$title" \
#    --command /bin/zsh -c \
#	'/opt/homebrew/bin/tmux new-session -s "'"$title"'" -e CLAUDE_CONTEXT_ID='"$ctx_id"' \; split-window -h "/opt/homebrew/bin/claude --dangerously-skip-permissions; zsh" \; select-pane -t 1'

#exec wezterm start \
#    --cwd ~/git \
#    --new-tab \
#    /bin/zsh -c \
#	'/opt/homebrew/bin/tmux new-session -s "'"$title"'" -e CLAUDE_CONTEXT_ID='"$ctx_id"' \; split-window -h "/opt/homebrew/bin/claude --dangerously-skip-permissions; zsh" \; select-pane -t 1'

exec wezterm start \
    --cwd ~/git \
    --new-tab \
    /bin/zsh -c 'export CLAUDE_CONTEXT_ID='"$ctx_id"'; exec zellij --session "'"$title"'" --layout cc-session'

