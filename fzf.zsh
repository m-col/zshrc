#
# fzf settings
#

if type fzf > /dev/null
then
    # I considered disabling ctrl-t to set it to type out fz, but the default
    # ctrl-t can be helpful for e.g. pytest, selecting and pasting paths.
    #bindkey -s '^t' "fv\n"

	#--preview 'bat -n --color=always {}'
	#--bind 'ctrl-/:change-preview-window(down|hidden|)'
    export FZF_DEFAULT_OPTS="
	--tmux
	--walker-skip .git,node_modules,target,.mypy_cache,.venv,__pycache__,.DS_Store,ws
	"
    export FZF_CTRL_T_COMMAND=""
    source <(fzf --zsh)

    _fzf-file-widget () {
	INIT_BUFFER="$LBUFFER"
	[[ -z "$INIT_BUFFER" ]] && LBUFFER="vim "

	local suffix=""
	[[ -n "$CLAUDE_CONTEXT_ID" ]] && suffix=".$CLAUDE_CONTEXT_ID"
	local context_file="$HOME/.local/share/claude/context-files${suffix}"
	local selected
	selected=$({
	    if [[ -f "$context_file" ]]; then
		local f rel
		while IFS= read -r f; do
		    [[ -f "$f" ]] || continue
		    rel="${f#$PWD/}"
		    echo "$rel"
		done < <(tail -r "$context_file")
	    fi
	    fd --type f --strip-cwd-prefix 2>/dev/null
	} | awk '!seen[$0]++' | fzf)

	if [[ -n "$selected" ]]; then
	    LBUFFER="${LBUFFER}${(q)selected}"
	    zle accept-line
	else
	    LBUFFER="$INIT_BUFFER"
	fi
    }

    zle     -N            _fzf-file-widget
    bindkey -M vicmd '^P' _fzf-file-widget
    bindkey -M viins '^P' _fzf-file-widget
fi
