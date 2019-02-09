#
# zshrc
#

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    export is_ssh=true
else
    export is_ssh=false
fi

ZSH="$HOME/.zsh"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
ZSH_COMPDUMP="$HOME/.zcompdump"
HISTFILE="$HOME/.zsh_history"
bindkey '^A' autosuggest-execute

for plugin ($ZSH/oh-my-zsh/*.zsh $ZSH/*.zsh)
do
    source $plugin
done


so () { [[ -e $1 ]] && source $1 }

so $ZSH/aliases	    # general aliases
so $HOME/.aliases   # machine-specific aliases

ZSH_THEME="ban"
so $ZSH/themes/$ZSH_THEME.zsh-theme

_Z_DATA=$HOME/.config/z
so $ZSH/z/z.sh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
so $ZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH () {
    zle &&  zle -R
}
