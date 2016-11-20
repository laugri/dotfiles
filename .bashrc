# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# *************************
# BASH PROMPT CUSTOMIZATION
# *************************

## ANSI color codes
RESET="\[\033[0m\]"    # reset
HICOLOR="\[\033[1m\]"    # hicolor
UNDERLINE="\[\033[4m\]"    # underline
INVERT="\[\033[7m\]"   # inverse background and foreground
T_BLACK="\[\033[30m\]" # foreground black
T_RED="\[\033[31m\]" # foreground red
T_GREEN="\[\033[32m\]" # foreground green
T_YELLOW="\[\033[33m\]" # foreground yellow
T_BLUE="\[\033[34m\]" # foreground blue
T_MAGENTA="\[\033[35m\]" # foreground magenta
T_CYAN="\[\033[36m\]" # foreground cyan
T_WHITE="\[\033[37m\]" # foreground white
BG_BLACK="\[\033[40m\]" # background black
BG_RED="\[\033[41m\]" # background red
BG_GREEN="\[\033[42m\]" # background green
BG_YELLOW="\[\033[43m\]" # background yellow
BG_BLUE="\[\033[44m\]" # background blue
BG_MAGENTA="\[\033[45m\]" # background magenta
BG_CYAN="\[\033[46m\]" # background cyan
BG_WHITE="\[\033[47m\]" # background white


## Helpers

function previous_cmd_status() {
    RETVAL=$?
    status=''
    if [ "${RETVAL}" == "0" ]
    then
        status=${RETVAL}
    else
        status=${RETVAL}
    fi
    echo -e "${status}"
}

# get current branch in git repo
function parse_git_branch() {
    BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
    if [ ! "${BRANCH}" == "" ]
    then
        echo "${BRANCH}"
    else
        echo ""
    fi
}

# get current status of git repo
function parse_git_dirty {
    status=`git status 2>&1 | tee`
    dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
    untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
    ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
    newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
    renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
    deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
    bits=''
    if [ "${renamed}" == "0" ]; then
        bits="r${bits}"
    fi
    if [ "${ahead}" == "0" ]; then
        bits="a${bits}"
    fi
    if [ "${newfile}" == "0" ]; then
        bits="n${bits}"
    fi
    if [ "${untracked}" == "0" ]; then
        bits="u${bits}"
    fi
    if [ "${deleted}" == "0" ]; then
        bits="d${bits}"
    fi
    if [ "${dirty}" == "0" ]; then
        bits="x${bits}"
    fi
    if [ ! "${bits}" == "" ]; then
        echo "${bits} "
    else
        echo ""
    fi
}


# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes


if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1="$HICOLOR$T_GREEN\`previous_cmd_status\` $T_WHITE\t $T_CYAN\W ${T_BLUE}($T_RED\`parse_git_branch\`${T_BLUE}) $T_YELLOW\`parse_git_dirty\`$RESET"
    # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1="\`previous_cmd_status\` \t \W \`parse_git_branch\` "
    # PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# Alias definitions.

# import aliases from ~/.bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Virtualenvwrapper

# export WORKON_HOME=$HOME/.virtualenvs
# export PROJECT_HOME=$HOME/Devel
# source /usr/local/bin/virtualenvwrapper.sh

# Fuck

eval "$(thefuck --alias)"

