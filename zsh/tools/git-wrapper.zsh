function _git-fuzzy-switch() {
    local result
    result=$(command git branch --all | fzf \
        --height 80% --layout=reverse \
        --print-query \
        --header 'enter: switch / type new name + enter to create' \
        --preview "command git log --graph --decorate --abbrev-commit --color=always --format=format:'%C(blue)%h%C(reset) - %C(green)(%ar)%C(reset)%C(yellow)%d%C(reset)%n  %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' \$(echo {} | sed -E 's/^[* ]?([^*]+).*/\1/' | sed -E 's|remotes/origin/||') 2>/dev/null" \
        --preview-window=right:60% \
        --ansi)

    local query=$(echo "$result" | sed -n '1p')
    local selected=$(echo "$result" | sed -n '2p')

    if [ -n "$selected" ]; then
        local branch_name=$(echo "$selected" | sed -E 's/^[* ]//' | sed -E 's/^[[:space:]]*//' | sed -E 's|remotes/origin/||')
        command git switch "$branch_name"
    elif [ -n "$query" ]; then
        command git switch -c "$query"
    fi
}

function _git-fuzzy-push() {
    local current_branch=$(command git rev-parse --abbrev-ref HEAD)
    local selected=$(command git branch | fzf --height 40% --layout=reverse \
        --query "$current_branch" \
        --ansi)

    [ -z "$selected" ] && return 1

    local branch_name=$(echo "$selected" | sed -E 's/^[* ]//' | sed -E 's/^[[:space:]]*//')
    command git push -u origin "$branch_name"
}

function git() {
    case "$1" in
        switch)
            if [[ "$#" -eq 1 ]]; then
                _git-fuzzy-switch
            else
                command git "$@"
            fi
            ;;
        push)
            if [[ "$#" -eq 1 ]] && ! command git rev-parse --abbrev-ref --symbolic-full-name @{u} &>/dev/null; then
                _git-fuzzy-push
            else
                command git "$@"
            fi
            ;;
        *)
            command git "$@"
            ;;
    esac
}
