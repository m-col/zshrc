#
# Set terminal window titles
#

function _set_title() {
    local a="%20>...>zsh"
    local b="%20<...<%~"
    printf '\33]2;%s:%s\007' ${(%)a} ${(%)b}
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _set_title
