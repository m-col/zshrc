### Segment drawing
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
    fi
}

prompt_git() {
    (( $+commands[git] )) || return
    local PL_BRANCH_CHAR
    () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    #PL_BRANCH_CHAR=$'\ue0a0'         # 
    PL_BRANCH_CHAR=$''
}
local ref dirty mode repo_path
repo_path=$(git rev-parse --git-dir 2>/dev/null)

if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
	prompt_segment yellow black
    else
	prompt_segment green black
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
	mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
	mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
	mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '+'
    zstyle ':vcs_info:*' unstagedstr '**'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n " ${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode} "
fi
}


prompt_dir() {
    prompt_segment magenta black ' %3~ '
}


prompt_mes() {
    [[ $RETVAL -ne 0 ]] && prompt_segment red black ' > '
    [[ $RETVAL -eq 0 ]] && prompt_segment blue black ' > '
}


prompt_virtualenv() {
    local virtualenv_path="$VIRTUAL_ENV"
    if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
	prompt_segment red black " (`basename $virtualenv_path`) "
    fi
}


prompt_status() {
    local symbols
    symbols=()
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}x"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"
    [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}


if $IS_SSH
then
    tmux_following_colour=green
else
    tmux_following_colour=magenta
fi
prompt_tmux() {
    local tmux_indicator
    local SEGMENT_SEPARATOR=''
    if $IS_TMUX
    then
	tmux_indicator=$'\ue0b0'
    else
	tmux_indicator=''
    fi
    [[ -n "$tmux_indicator" ]] && prompt_segment $tmux_following_colour 11 "$tmux_indicator"
}


export KEYTIMEOUT=1	# reduce delay to 0.1s
bindkey -v
prompt_vi(){
    # only add to prompt if not empty
    [[ -n $VIM_PROMPT ]] && prompt_segment default white $VIM_PROMPT
}
zle-line-init() { zle -K viins; }
zle -N zle-line-init


## Main left prompt
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
    prompt_git
    prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
RPROMPT='%{%f%b%k%}$(build_rprompt)'

# redraw prompt on mode changes
zle-keymap-select() {
    if [ $KEYMAP = vicmd ]; then
	printf "\033[2 q" # block cursor
	VIM_PROMPT=" -- NORMAL -- "
    else
	printf "\033[4 q" # underline. Change 4 to 6 for vertical line
	VIM_PROMPT=""
    fi

    PROMPT='%{%f%b%k%}$(build_prompt) '
    RPROMPT='%{%f%b%k%}$(build_rprompt)'
    zle reset-prompt
    zle -R
}
zle -N zle-keymap-select

#PROMPT='%{$FG[001]%}> %{$reset_color%}'
#RPROMPT='%{$FG[001]%}%2~ $(git_prompt_info)$(git_prompt_status)%{$reset_color%}'


#ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}✗%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_PREFIX="("
#ZSH_THEME_GIT_PROMPT_SUFFIX=")"

#ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[magenta]%}["
#ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_DIRTY=""
#ZSH_THEME_GIT_PROMPT_CLEAN=""
#ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[cyan]%}+"
#ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}*"
#ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}x"
#ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}~"
#ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%}><"
#ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}**"

# vim:ft=sh
