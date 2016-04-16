#!/bin/bash

usage() {
    echo "Usage: $0 [-r REPO] [-h]"
    echo "    -r      Git repo to pull profile"
    echo "    -h      Print this help menu"
    exit 5
}

install_homebrew() {
    MAC=`which sw_vers | wc -l`
    if [[ "$MAC" == "0" ]]; then
        return 0
    fi

    MAC_VER=`sw_vers -productVersion | awk -F'.' '{print $2}'`
    if [[ "$MAC_VER" -lt "9" ]]; then
        return 0
    fi

    BREW=`which brew | wc -l`
    if [[ "$BREW" == "0" ]]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    return 1
}

# Set up homebrew and install packages
INSTALL=install_homebrew

if [[ "$INSTALL" == "1" ]]; then
    BREW_PACKAGES=(wget git bash-completion bash-git-prompt multitail pcre tree)
    for PKG in "${BREW_PACKAGES[@]}"; do
        if [ ! -d "/usr/local/Cellar/${PKG}" ]; then
            brew install $PKG
        fi
    done
fi


REPO=

while getopts :r:h FLAG; do
    case $FLAG in
        r)  REPO=$FLAG
            ;;
        h)  usage
            ;;
    esac
done

if [[ -z $REPO ]]; then
    echo "Missing git repo URL."
    usage
fi


# Set up git repos for profile data
# Need SSH key first
mkdir ~/.my_profile
cd ~/.my_profile
git clone $REPO


# Set up profile symlinks
PROFILE=(.bash.d .chef .config .profile .ssh .vim .vimrc)
BACKUP="~/profile_backup"
mkdir $BACKUP
for ITEM in "${PROFILE[@]}"; do
    if [[ (-f ~/$ITEM && ! -L ~/$ITEM) || -d ~/$ITEM ]]; then
        mv ~/$ITEM ~/$BACKUP/
        ln -s ~/$ITEM ~/.my_profile/$ITEM
    fi
done


