#!/bin/bash
# Set up Jon's Unix environment with a single script.

# Text color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldyll=${txtbld}$(tput setaf 3) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
header=$(tput sgr 1 1)
info=${bldwht}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

# Red text
function echo_r {
    echo "${bldred}$1${txtrst}"
}

# Green text
function echo_g {
    echo "${bldgrn}$1${txtrst}"
}

function echo_b {
    echo "${bldblu}$1${txtrst}"
}

function echo_y {
    echo "${bldyll}$1${bldylltxtrst}"
}

function header {
    echo
    echo "${header}$1${txtrst}"
    echo
}

function info {
    echo "${info}$1${txtrst}"
}

function apt {
    run sudo apt-get install $*
}

die() { echo >&2 -e "${bldred}\nERROR: $@${txtrst}\n"; exit 1; }
run() { $*; code=$?; [ $code -ne 0 ] && die "command [$*] failed with error code $code"; }

function install_term {
    do_install zsh
    if $do_install
    then
        echo_b "Installing zsh"
        apt zsh
    fi
    do_install tmux
    if $do_install
    then
        echo_b "Installing tmux"
        apt tmux
    fi
}

function do_install {
    installed $1
    do_install=false
    if ! $is_installed
    then
        if [ "$2" ]
        then
            yes_or_no $2
        else
            yes_or_no "Install $1?"
        fi
        if $answered_yes
        then
            do_install=true
        fi
    fi
}

function installed {
    prog=$1
    echo
    echo_b "Checking for $prog"
    if command -v $prog >/dev/null 2>&1
    then
        echo_g "-> $prog is already installed"
        is_installed=true
    else
        echo_r "-> $prog is not installed"
        is_installed=false
    fi
}

function yes_or_no {
    txt=$1
    echo
    read -n1 -p "${bldyll}$txt [y,N] ${txtrst}" answered_yes 
    echo
    case $answered_yes in
        y|Y) answered_yes=true ;;
        n|N) answered_yes=false;;
        *) yes_or_no $txt
    esac
}

header "Welcome to Jon's Unix environment installer!"
info "All dotfiles will be installed to $HOME"

install_term
echo_g "Updating submodules"
git submodule init && git submodule update
cd myvim && git submodule init && git submodule update
echo_g "Configuring tmux"
ln -s $PWD/abs_path tmux.conf ~/.tmux.conf
ln -s $PWD/tmux.conf.local ~/.tmux.conf.local
echo_g "Configuring vim"
rm -r ~/.vim/ ~/.vimrc
ln -s $PWD/myvim/ ~/.vim
ln -s $PWD/myvim/vimrc ~/.vimrc
mkdir -p  ~/.vim-tmp

echo
echo_g "Enjoy."
