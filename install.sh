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
    echo "${bldyll}$1${txtrst}"
}

function header {
    echo "${header}$1${txtrst}"
}

function info {
    echo "${info}$1${txtrst}"
}

function install_ruby {
    installed ruby
    if ! $is_installed
    then
        echo " -> Installing ruby via RVM"
        \curl -L https://get.rvm.io | bash -s stable --ruby
    fi
}

function installed {
    prog=$1
    echo
    echo_b "Checking for $prog"
    if command -v $prog >/dev/null 2>&1
    then
        echo_g " -> $prog is installed"
        is_installed=true
    else
        echo_b " -> $prog is not installed"
        is_installed=false
    fi
}

function yes_or_no {
    read -n1 -p "${bldyll}$1 [y,N] ${txtrst}" answered_yes 
    echo
    case $answered_yes in
        y|Y) answered_yes=true ;;
        n|N) answered_yes=false;;
        *) yes_or_no $1
    esac
}

header "Welcome to Jon's Unix environment installer!"
echo
info "All dotfiles will be installed to $HOME"

yes_or_no Continue?
if $answered_yes
then
    echo_g "Excellent!"
    echo
else
    echo_r "Go away then." && exit 1
fi

echo_b "Installing required packages"
sudo apt-get install curl

install_ruby
