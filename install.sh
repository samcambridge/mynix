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

function install_sqlite {
    do_install sqlite3
    if $do_install
    then
        echo_b "Installing sqlite3 and libsqlite3-dev"
        apt libsqlite3-dev sqlite3
    fi
}

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

function install_pg {
    do_install psql "Install postgresql and dev libraries?"
    if $do_install
    then
        echo_b "Installing postgres and libsqlite3-dev"
        apt postgresql-9.1 postgresql-server-dev-9.1 postgresql-client-9.1
    fi
}

function install_ruby {
    do_install ruby
    if $do_install
    then
        echo_b "Installing ruby via RVM - go and have a cup of tea."
        run \curl -L https://get.rvm.io | bash -s stable --ruby
    fi
}

function install_php {
    do_install php "Install php (fastcgi + cli)?"
    if $do_install
    then
        echo_b "Installing php5-cgi, php5-cli and others"
        apt php5-cli php5-cgi php5-curl php5-dev php5-gd php5-sqlite php5-xdebug
    fi
}

function install_vim {
    yes_or_no "Install vim from source?"
    if $answered_yes
    then
        echo_b "Removing any existing vim"
        run sudo apt-get purge vim vim-gnome vim-gtk vim-tiny vim-scripts
        echo_b "Installing required tools and libraries"
        apt mercurial python python-dev libncurses-dev libgnome2-dev \
           libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev \
           libx11-dev libxpm-dev libxt-dev libcurses-dev
        run hg clone https://vim.googlecode/hg/ vim
        run cd vim
        rubypath=$(which ruby)
        run ./configure --with-features=HUGE \
            --enable-pythoninterp=yes \
            --with-python-config-dir=/usr/lib/python2.7/config/ \
            --enable-multibyte=yes \
            --enable-cscope=yes \
            --enable-rubyinterp=yes \
            --with-ruby-command=$(rubypath) \
            --enable-gui=gnome2 \
            --with-x \
            --enable-fontset
        run make
        run sudo make install
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

yes_or_no Continue?
if $answered_yes
then
    echo_g "Excellent!"
    echo
else
    echo_r "Go away then." && exit 1
fi

echo_b "Installing required packages"
apt curl git

install_sqlite
install_pg
install_ruby
install_php
install_term

echo
echo_g "Congratulations, you have made it all the way through!"
echo_g "Enjoy."
