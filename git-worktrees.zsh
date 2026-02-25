case "${WAYLAND_DISPLAY:+wayland}${DISPLAY:+x11}$OSTYPE" in
    wayland*)
        _copy='wl-copy'
        ;;
    x11*)
        _copy='xclip -selection clipboard'
        ;;
    darwin*)
        _copy=pbcopy
        ;;
esac

# Add a worktree - creates branch from main if it doesn't exist
gw() {
    local input="$1"
    if [[ -z "$input" ]]; then
	git worktree list
        return 1
    fi

    local branch="${input##origin/}"
    local folder="${branch//\//-}"
    echo -n "$folder" | $_copy
    local target="../$folder"

    # Check if worktree already exists
    if [[ -d "$target" ]]; then
        cd "$target"
        return
    fi
    
    # Check if branch exists locally
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        git worktree add "$target" "$branch" && cd "$target"
        return
    fi
    
    # Try fetching from remote
    if git fetch origin "$branch" 2>/dev/null && \
       git worktree add "$target" "$branch" 2>/dev/null; then
        cd "$target"
        return
    fi
    
    # Branch doesn't exist - create from main
    echo "Branch '$branch' not found, creating from main..."
    git fetch origin main:main 2>/dev/null || git fetch origin main
    git worktree add -b "$branch" "$target" main && cd "$target"
}

# cd to top-level folder of a worktree if we're inside a subfolder, otherwise cd to main
gw_top_level() {
    local root="${HOME}/git/$1"

    # Check if we're inside a subfolder of the repo
    if [[ "$PWD" == "$root"/* ]]; then
        # Extract path relative to root, then get first component
        local relative="${PWD#$root/}"
        local subfolder="${relative%%/*}"
        cd "$root/$subfolder"
    else
        cd "$root/main"
    fi
}

# Remove a worktree
gwr() {
    if [[ "$(git rev-parse --is-inside-work-tree)" != "true" ]]; then
        echo "Not in a worktree"
        return 1
    fi
    cd $(git rev-parse --show-toplevel)
    local target="${1:-$(basename "$PWD")}"

    if [[ "$target" == "main" ]]; then
        echo "Refusing to remove main worktree"
        return 1
    fi

    local branch
    if [[ -z "$1" ]]; then
        # Current directory - get branch before leaving
        branch=$(git branch --show-current)
        cd ../main && git worktree remove "../$target" && git branch -D "$branch"
    else
        # Named worktree - get its branch first
        branch=$(git -C "../$target" branch --show-current 2>/dev/null)
        git worktree remove "../$target" && [[ -n "$branch" ]] && git branch -D "$branch"
    fi
    git worktree list
}

# Interactive branch selection with fzf
gwf() {
    local branch=$(git branch -a --sort=-committerdate | \
        grep -v HEAD | \
        sed 's/^[* ]*//' | \
        sed 's#remotes/origin/##' | \
        awk '!seen[$0]++' | \
        fzf --height 40% --reverse --preview 'git log --oneline -10 {}')
    [[ -n "$branch" ]] && gwt "$branch"
}

# Completions
_gw_branches() {
    local branches
    branches=(${(f)"$(git branch 2>/dev/null | sed 's/^[* ]*//' | sed 's/^[+ ]*//')"})
    _describe 'branch' branches
}

_gwr_worktrees() {
    local worktrees
    worktrees=(${(f)"$(git worktree list --porcelain 2>/dev/null | grep '^worktree' | awk '{print $2}' | xargs -n1 basename)"})
    _describe 'worktree' worktrees
}

compdef _gw_branches gw
compdef _gwr_worktrees gwr
