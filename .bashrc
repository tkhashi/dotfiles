#set -o vi
# Command
alias tree='tree -N'
alias lsgr='ls -la | grep'

# Directory
alias wcd='cd ~/work/'
alias scd='cd ~/work/smakan/'
alias sccd='cd ~/work/screening.poc/'
alias dcd='cd ~/work/dotfiles/'
alias rcd='cd ~/work/smakan.module.report/'
alias nvnv='nvim ~/work/dotfiles/nvim/'

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

# GITLAB
alias gltl='glab mr list | grep $(git rev-parse --abbrev-ref HEAD)'
alias glls='glab mr list'

#SMKN
alias sm='git switch SMKN2-'

#GCP
alias fss='npx firebase emulators:start'
alias fssa='npx firebase emulators:start --import ../../OneDrive/デスクトップ/202209_atsugi_new/'

# Application
alias chrome='/c/Program\ Files/Google/Chrome/Application/chrome.exe'
alias n='nvim'
export LANG=ja_JP.UTF-8
eval "$(oh-my-posh init bash --config ~/jandedobbeleer.omp.json)"
# eval "$(starship init bash)"
# eval "$(zoxide init bash)"

# completion
source <(glab completion -s bash)

[ -f ~/.inshellisense/key-bindings.bash ] && source ~/.inshellisense/key-bindings.bash

# Option
alias memo='cd ~/work/memo'
