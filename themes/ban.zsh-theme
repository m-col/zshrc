# vim:ft=zsh
#
# ban zsh theme
#

# Segment drawing

# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

# Special Powerline characters
() {
local LC_ALL="" LC_CTYPE="en_US.UTF-8"

# prompt segment shape: arrow or square
if $IS_SSH
then
    SEGMENT_SEPARATOR_L=$'\ue0b0'
    SEGMENT_SEPARATOR_R=$''
else
    SEGMENT_SEPARATOR_L=$''
    SEGMENT_SEPARATOR_R=$''
fi
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
	echo -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
    else
	echo -n "%{$bg%}%{$fg%}"
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
    if [[ -n $CURRENT_BG ]]; then
	echo -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
    else
	echo -n "%{%k%}"
    fi
    echo -n "%{%f%}"
    CURRENT_BG=''
}

prompt_context() {
    if $IS_SSH; then
	prompt_segment green black " %(!.%{%F{yellow}%}.)$USER@$HOST "
    elif [[ $EUID -eq 0 ]]; then
	prompt_segment red black " %(!.%{%F{black}%}.)$USER@$HOST "
    fi
}

#source $HOME/.zsh/gitstatus/gitstatus.plugin.zsh
#gitstatus_start MY
#prompt_git() {
#    local PL_BRANCH_CHAR
#    () {
#	local LC_ALL="" LC_CTYPE="en_US.UTF-8"
#	PL_BRANCH_CHAR=$'\ue0a0'
#    }
#
#    gitstatus_query MY                  || return 1  # error
#    [[ $VCS_STATUS_RESULT == ok-sync ]] || return 0  # not a git repo
#
#    local     clean='%F{076}'  # green foreground
#    local untracked='%F{014}'  # teal foreground
#    local  modified='%F{011}'  # yellow foreground
#
#    local p
#    if (( VCS_STATUS_HAS_STAGED || VCS_STATUS_HAS_UNSTAGED )); then
#	p+=$modified
#    elif (( VCS_STATUS_HAS_UNTRACKED )); then
#	p+=$untracked
#    else
#	p+=$clean
#    fi
#    p+=${${VCS_STATUS_LOCAL_BRANCH:-@${VCS_STATUS_COMMIT}}//\%/%%}            # escape %
#
#    #[[ -n $VCS_STATUS_TAG               ]] && p+="#${VCS_STATUS_TAG//\%/%%}"  # escape %
#    [[ $VCS_STATUS_HAS_STAGED      == 1 ]] && p+="${modified}+"
#    [[ $VCS_STATUS_HAS_UNSTAGED    == 1 ]] && p+="${modified}!"
#    [[ $VCS_STATUS_HAS_UNTRACKED   == 1 ]] && p+="${untracked}?"
#    [[ $VCS_STATUS_COMMITS_AHEAD  -gt 0 ]] && p+="${clean} ⇡${VCS_STATUS_COMMITS_AHEAD}"
#    [[ $VCS_STATUS_COMMITS_BEHIND -gt 0 ]] && p+="${clean} ⇣${VCS_STATUS_COMMITS_BEHIND}"
#    #[[ $VCS_STATUS_STASHES        -gt 0 ]] && p+="${clean} *${VCS_STATUS_STASHES}"
#
#    prompt_segment default green "${p}"
#}


prompt_dir() {
    prompt_segment magenta black ' %3~ '
}


prompt_mes() {
    if [[ $RETVAL -ne 0 ]]
    then
	prompt_segment red black ' > '
    else
	prompt_segment blue black ' > '
    fi
}


prompt_virtualenv() {
    local virtualenv_path="$VIRTUAL_ENV"
    if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
	prompt_segment red black " (`basename $virtualenv_path`) "
    fi
}


#prompt_status() {
#    local symbols
#    symbols=()
#    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}x"
#    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
#    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"
#    [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
#}


if $IS_SSH
then
    tmux_following_colour=green
elif [[ $EUID -eq 0 ]]
then
    tmux_following_colour=red
else
    tmux_following_colour=magenta
fi
if $IS_TMUX
then
    tmux_indicator=$'\ue0b0'
else
    tmux_indicator=''
fi
prompt_tmux() {
    local SEGMENT_SEPARATOR=''
    [[ -n "$tmux_indicator" ]] || return 0
    prompt_segment $tmux_following_colour 11 "$tmux_indicator"
}


export KEYTIMEOUT=1	# reduce delay to 0.1s
bindkey -v
prompt_vi(){
    # only add to prompt if not empty
    [[ -n $VIM_PROMPT ]] && prompt_segment default white $VIM_PROMPT
}
zle-line-init() { zle -K viins; }
zle -N zle-line-init


build_prompt() {
    RETVAL=$?
    local SEGMENT_SEPARATOR=$SEGMENT_SEPARATOR_L
    prompt_tmux
    prompt_context
    prompt_dir
    prompt_mes
    prompt_end
}

build_rprompt() {
    RETVAL=$?
    local SEGMENT_SEPARATOR=$SEGMENT_SEPARATOR_R
    prompt_virtualenv
    prompt_vi
    #prompt_git
    prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
RPROMPT='%{%f%b%k%}$(build_rprompt)'

# redraw on mode change
zle-keymap-select() {
    if [[ $KEYMAP == vicmd ]]; then
	printf "\033[2 q" # block cursor
	VIM_PROMPT=" -- NORMAL -- "
    else
	printf "\033[4 q" # underline. Change 4 to 6 for vertical line
	VIM_PROMPT=""
    fi

    zle reset-prompt
    zle -R
}
zle -N zle-keymap-select
