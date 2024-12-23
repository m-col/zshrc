#
# misc functions
#

# use last browsed directory automatically with ranger
_ranger=`which ranger`
ranger-cd() { 
    tempfile="$(mktemp -t ranger.XXXXXX)"
    if [[ -f $HOME/.local/bin/ranger ]]
    then
	$HOME/.local/bin/ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    else
	$_ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    fi
    test -f "$tempfile" &&
	if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
	    cd -- "$(cat "$tempfile")"
	fi
	rm -f -- "$tempfile"
}
ranger() { # prevent nested ranger instances when shelling from ranger
    if [ -z "$RANGER_LEVEL" ]; then
	ranger-cd "$@"
    else
	exit
    fi
}

shebang() { # create new file, add shebang, and vim
    touch $1
    chmod +x $1
    echo -e "#!/usr/bin/env bash\n" > $1
    vim +2 $1
}
shebangpy() { # create new file, add shebang, and vim
    touch $1
    chmod +x $1
    echo -e "#!/usr/bin/env python3\n" > $1
    vim +2 $1
}

# copy file path to clipboard
cpath() { readlink -f $1 | copy }



sb () {
    sed 's/.*/\L&/g; s/\(.\{1\}\)\(.\)/\1\U\2/g' <<< "$@"
}


hex_fg() {
    #eval printf \"x1b[38\;2\;$(printf "\$((16#%s));\$((16#%s));\$((16#%s))\n" $(echo ${1//#} | fold -w2))m\"  # <- works up to leading escape
    eval printf \\\\\"x1b[38\;2\;$(printf "\$((16#%s));\$((16#%s));\$((16#%s))\n" $(echo ${1//#} | fold -w2))m\"
}

hex_bg() {
    #eval printf \"x1b[38\;2\;$(printf "\$((16#%s));\$((16#%s));\$((16#%s))\n" $(echo ${1//#} | fold -w2))m\"  # <- works up to leading escape
    eval printf \\\\\"x1b[48\;2\;$(printf "\$\(\(16#%s\)\);\$\(\(16#%s\)\);\$\(\(16#%s\)\)\n" $(echo ${1//#} | fold -w2))m\"
}

avi_to_mp4() {
    ffmpeg -i $1 -c:v libx264 -preset slow -crf 19 -c:a libvo_aacenc -b:a 128k $2
}

rec_screen() {
    if [[ -n "$WAYLAND_DISPLAY" ]]
    then
	wf-recorder
    else
	ffmpeg -f x11grab -r 30 -s 1920x1080 -i $DISPLAY -pix_fmt yuv420p out.mp4
    fi
}
rec_screen_mic() {
    ffmpeg -f x11grab -r 30 -s 1920x1080 -i $DISPLAY -f pulse -ac 2 -i default out.mkv
}

tagans() {
    git log --pretty=format:"%an" $1...$2 | sort -u
}
