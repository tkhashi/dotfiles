# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/kazuhiro.takahashi/.zsh/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

#set -o vi
# Command
alias tree='tree -N'
alias lsgr='ls -la | grep'

# Directory
alias wcd='cd ~/Documents/work/'
alias nvnv='nvim ~/work/dotfiles/nvim/'
alias nv='nvim'

# Git
alias g='git'
alias ga='git add .'
gcm (){
  git commit -m "$1 $2 $3 $4 $5 $6 $7 $8 $9"
}
alias gca='git commit --amend'
alias gcane='git commit --amend --no-edit'
alias gd='git diff'
alias gs='git status'
alias gb='git branch'
alias gc='git checkout'
alias gw='git switch'
alias gwc='git switch -c'
alias gf='git fetch'
alias gl='git log'
alias gpl='git pull'
alias gp='git push'
alias gpu='current_branch=$(git branch --show-current); git push --set-upstream origin $current_branch'
gi (){
    # カレントディレクトリに".gitignore"が存在するかチェック
    if [ -e .gitignore ]; then
        echo "Already exist .gitignore. Current content of .gitignore:"
        echo ""
        echo "==============================================================="
        cat .gitignore
        echo "==============================================================="
        echo ""

        read -p "Append  to .gitignore? (y/n): " answer
        if [ "$answer" == "y" ]; then
            # "git ignore"コマンドの出力結果をファイルに追記
            git ignore "$1, $2, $3, $4, $5" >> .gitignore
            echo "Appended  to .gitignore"
        else
            echo "Operation canceled"
        fi
    else
        touch .gitignore
        git ignore "$1, $2, $3, $4, $5" >> .gitignore
        echo "Created .gitignore"
    fi
}

# Application
alias chrome='/c/Program\ Files/Google/Chrome/Application/chrome.exe'
alias karabiner_cli='/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli'
alias n='nvim'
export LANG=ja_JP.UTF-8

# Tools
# eval "$(oh-my-posh init bash --config ~/jandedobbeleer.omp.json)"
# eval "$(starship init bash)"
# eval "$(zoxide init bash)"
## eza
alias lsla='eza -la'
alias ls='eza'
## autojump
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
## Cloudflare
export NODE_EXTRA_CA_CERTS=/usr/local/share/cloudflare/certificates/certificate.pem
export NODE_USE_SYSTEM_CA=1

[ -f ~/.inshellisense/key-bindings.bash ] && source ~/.inshellisense/key-bindings.bash

function git_clone_auto() {
    local repo_url="$1"
    local host_alias="company"  # デフォルトは 'company'

    # ホストエイリアスの決定
    case "$PWD" in
        "$HOME"/Documents/github | "$HOME"/Documents/github/**)
            host_alias="private"
            ;;
    esac

    if [[ "$repo_url" == git@github.com:* ]]; then
        local repo_path="${repo_url#git@github.com:}"
        echo "実行コマンド: git clone git@${host_alias}:${repo_path}"
        git clone "git@${host_alias}:${repo_path}"
    else
        echo "実行コマンド: git clone $repo_url"
        git clone "$repo_url"
    fi
}

alias gitclone='git_clone_auto'




. "$HOME/.local/bin/env"
source /Users/kazuhiro.takahashi/.safe-chain/scripts/init-posix.sh # Safe-chain Zsh initialization script
