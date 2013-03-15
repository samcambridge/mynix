#!/bin/bash
function install_ruby {
    if which ruby
    then
        echo "Ruby is installed"
    else
        echo "No rubies."
    fi
}

function yes_or_no {
    read -n1 -p "$1 [y,N] " answered_yes 
    echo
    case $answered_yes in
        y|Y) answered_yes=true ;;
        n|N) answered_yes=false;;
        *) yes_or_no $1
    esac
}

echo "Welcome to Jon's Unix environment installer!\n"
echo "All dotfiles will be installed to $HOME"

yes_or_no Continue?
if $answered_yes
then
    echo "Excellent!"
else
    echo "Go away then." && exit 1
fi
