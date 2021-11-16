#
# Set ~g to point to current git root
#

#function _set_groot() {
#    local groot
#    if groot=$(git rev-parse --show-toplevel 2> /dev/null)
#    then
#	hash -d g="$groot"
#    else
#	disable g
#    fi
#}
#
#autoload -Uz add-zsh-hook
#add-zsh-hook precmd _set_groot
