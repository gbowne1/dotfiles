# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# History settings
HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize

# Use colors in prompt if terminal supports it
if [[ "$TERM" =~ (xterm|rxvt|.*-256color) ]] && [ -x /usr/bin/tput ] && tput setaf 1 &> /dev/null; then
    use_color=true
fi

# Define colors
if [ "$use_color" = true ]; then
    red='\[\e[0;31m\]'
    RED='\[\e[1;31m\]'
    blue='\[\e[0;34m\]'
    BLUE='\[\e[1;34m\]'
    cyan='\[\e[0;36m\]'
    CYAN='\[\e[1;36m\]'
    green='\[\e[0;32m\]'
    GREEN='\[\e[1;32m\]'
    yellow='\[\e[0;33m\]'
    YELLOW='\[\e[1;33m\]'
    purple='\[\e[0;35m\]'
    PURPLE='\[\e[1;35m\]'
    nc='\[\e[0m\]'
else
    red=''; RED=''; blue=''; BLUE=''
    cyan=''; CYAN=''; green=''; GREEN=''
    yellow=''; YELLOW=''; purple=''; PURPLE=''
    nc=''
fi

# Set prompt based on UID
if [ "$UID" = 0 ]; then
    PS1="${red}\u${nc}@${red}\H${nc}:${CYAN}\w${nc}\n${red}#${nc} "
else
    PS1="${PURPLE}\u${nc}@${CYAN}\H${nc}:${GREEN}\w${nc}\n${GREEN}\$${nc} "
fi

# Set terminal title if supported
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        ;;
esac

# Enable color support for ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
    alias ls='ls --color=auto'
fi

alias ll='ls -lh'
alias la='ls -A'
alias l='ls -CF'

# Source .bash_aliases if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Default parameter for 'less'
export LESS="-R -i"

# Enable programmable completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Add sbin directories to PATH if not already present
[[ ":$PATH:" != *":/sbin:"* ]] && PATH="$PATH:/sbin"
[[ ":$PATH:" != *":/usr/sbin:"* ]] && PATH="$PATH:/usr/sbin"

# Load NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Function to extract various archive types
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"    ;;
      *.tar.gz)    tar xzf "$1"    ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       command -v unrar &> /dev/null && unrar x "$1" || 7z x "$1" ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar xf "$1"     ;;
      *.tbz2)      tar xjf "$1"    ;;
      *.tgz)       tar xzf "$1"    ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Set default editor
export EDITOR='vim'

# Load additional configs from ~/.bashrc.d
if [ -d ~/.bashrc.d ]; then
  for file in ~/.bashrc.d/*; do
    [ -f "$file" ] && . "$file"
  done
fi

# Automatically start tmux if not already running
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux attach -t default || tmux new -s default
fi
