function _git-fuzzy-switch() {
    local current_branch=$(command git rev-parse --abbrev-ref HEAD)
    local branches=$(command git branch --all)
    local selected=$(echo -e "${branches}\n  (create from \"${current_branch}\")" | fzf --height 80% --layout=reverse \
        --preview "if [[ {} != *\"create from\"* ]]; then command git log --graph --decorate --abbrev-commit --color=always --format=format:'%C(blue)%h%C(reset) - %C(green)(%ar)%C(reset)%C(yellow)%d%C(reset)%n  %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' \$(echo {} | sed -E 's/^[* ]?([^*]+).*/\1/' | sed -E 's|remotes/origin/||') 2>/dev/null; fi" \
        --preview-window=right:60% \
        --ansi)

    [ -z "$selected" ] && return 1

    if [[ "$selected" == "  (create from \"${current_branch}\")" ]]; then
        printf "Input new branch name: "
        read new_branch
        [ -z "$new_branch" ] && return 1
        command git switch -c "$new_branch"
    else
        local branch_name=$(echo "$selected" | sed -E 's/^[* ]//' | sed -E 's/^[  ]//' | sed -E 's|remotes/origin/||')
        command git switch "$branch_name"
    fi
}

function _git-fuzzy-push() {
    local current_branch=$(command git rev-parse --abbrev-ref HEAD)
    local selected=$(command git branch | fzf --height 40% --layout=reverse \
        --query "$current_branch" \
        --ansi)

    [ -z "$selected" ] && return 1

    local branch_name=$(echo "$selected" | sed -E 's/^[* ]//')
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
