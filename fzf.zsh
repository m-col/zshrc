#
# fzf settings
#

if type fzf > /dev/null
then
    # I considered disabling ctrl-t to set it to type out fz, but the default
    # ctrl-t can be helpful for e.g. pytest, selecting and pasting paths.
    #bindkey -s '^t' "fv\n"
    #export FZF_CTRL_T_COMMAND=""

    export FZF_DEFAULT_OPTS="
	--preview 'bat -n --color=always {}'
	--bind 'ctrl-/:change-preview-window(down|hidden|)'
	--tmux
	--walker-skip .git,node_modules,target,.mypy_cache,.venv,__pycache__,.DS_Store
	"
    source <(fzf --zsh)
fi
