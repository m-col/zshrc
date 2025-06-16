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
	--walker-skip .git,node_modules,target,.mypy_cache,.venv,__pycache__,.DS_Store
	"
    export FZF_CTRL_T_COMMAND=""
    source <(fzf --zsh)

    _fzf-file-widget () {
	INIT_BUFFER="$LBUFFER"
	[[ -z "$INIT_BUFFER" ]] && LBUFFER="vim "
	fzf-file-widget
	if [[ $? -eq 0 ]]
	then
	    zle accept-line
	else
	    LBUFFER="$INIT_BUFFER"
	fi
    }

    zle     -N            _fzf-file-widget
    bindkey -M vicmd '^P' _fzf-file-widget
    bindkey -M viins '^P' _fzf-file-widget
fi
