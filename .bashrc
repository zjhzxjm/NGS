# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
alias today="date +%F"

alias ll="ls -l -h  --time-style="long-iso" "
alias le="less -S"
alias grep='egrep --color=auto'
alias df='df -h'
alias du='du -h --max-depth=1'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'


PS1="\[\e[1;32m\][\u@\h:\[\e[1;31m\] \# \[\e[1;36m\]\W]$\[\e[m\]"
export PS1
