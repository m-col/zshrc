#
# zshrc
#

if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]
then
    export IS_SSH=true
else
    export IS_SSH=false
fi

if [[ -n "$TMUX" ]]
then
    export IS_TMUX=true
else
    export IS_TMUX=false
fi

# zsh settings
local ZSH="$HOME/.zsh"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
ZSH_COMPDUMP="$HOME/.zcompdump"
setopt NO_nomatch
fpath=(~/.zfunc $fpath)

# zsh history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=12000
SAVEHIST=8000
#setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# plugins
for plugin ($ZSH/oh-my-zsh/*.zsh $ZSH/*.zsh(N))
do
    source $plugin
done

so () { [[ -e $1 ]] && source $1 }

so $ZSH/aliases		    # common
so $HOME/.config/aliases    # machine-specific

ZSH_THEME="ban"
so $ZSH/themes/$ZSH_THEME.zsh-theme

_Z_DATA=$ZSH/z_data
so $ZSH/z/z.sh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
so $ZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

LESSHISTFILE=-

bindkey '^A' autosuggest-execute

export SUDO_EDITOR=vim
export EDITOR=vim
export AUR_PAGER=ranger

# ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH () { zle &&  zle -R }

# these are needed for some unicode to work (e.g. in tmux)
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# don't load default ranger config
export RANGER_LOAD_DEFAULT_RC=FALSE

export PYTHONPATH=$HOME/git/reach:$PYTHONPATH

# mypy
export MYPYPATH=$PYTHONPATH

export PAGER="less --mouse"

# If being executed via the '2' script
if [[ -n "$DO2" ]]
then
    z $DO2
    unset DO2
fi
