#!/bin/bash

# Setup the environment
#
# This script is used to setup the environment for the rest of the
# scripts.
#
# This script is called by the main script.

# Packages to install
# This is a list of packages to install.

packages=(git gitk vim sublime-text brave chromium chrome intellij-toolbox code Postman mongodb mysql)
echo "Installing packages..."

# The script will install these packages.
# The script will also install the packages that are required by the packages in this list.

for name in ${packages[@]}; do
    echo "Installing $name..."
    if [ ! -x "$(command -v $name)" ]; then
        echo "Package $name is not installed. Do you want to install it? (y/n)"
        read answer
        if [ "$answer" == "y" ]; then
            sudo apt-get install $name
        fi
        else
            echo "Package $name is already installed."
    fi
done