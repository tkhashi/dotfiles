#set -o vi
# Command
alias tree='tree -N'

# Directory
alias wcd='cd ~/work/'
alias scd='cd ~/work/smakan/'
alias dcd='cd ~/Desktop'
alias rcd='cd ~/work/smakan.module.report/'

# Git
alias g='git'
alias ga='git add .'
# alias gcm='git commit -m'
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

#SMKN
alias sm='git switch SMKN2-'

#GCP
alias fss='npx firebase emulators:start'
alias fssa='npx firebase emulators:start --import ../../Desktop/202209_atsugi'
# Application
alias chrome='/c/Program\ Files/Google/Chrome/Application/chrome.exe'
export LANG=ja_JP.UTF-8
eval "$(oh-my-posh init bash --config ~/jandedobbeleer.omp.json)"
