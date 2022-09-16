#!/bin/bash

# Setup the environment
#
# This script is used to setup the environment for the rest of the
# scripts.
#
# This script is called by the main script.

# Packages to install
# This is a list of packages to install.

packages=(git gitk vim sublime-text brave chromium chrome intellij-toolbox code Postman mongodb)
echo "Installing packages..."

# The script will install these packages.
# The script will also install the packages that are required by the packages in this list.

for name in "${packages[@]}"; do
    echo "Installing $name..."
    if [ ! -x "$(command -v "$name")" ]; then
        echo "Package $name is not installed. Do you want to install it? (y/n)"
        read -r answer
        if [ "$answer" == "y" ]; then
            search_result=$(sudo apt-cache search --names-only "$name" || wc -l)
            if [ "$search_result" -gt 0 ]; then
                sudo apt-get install "$name"
            fi
            else
                # TODO: tar/deb file download via source
                # 1. Decide source's repo (Mantain all sources list).
                # 2. Download tar/deb
                # 3. For tar - verify sha & extract to /opt (unique folder)
                # 4. For deb - install via dpkg command
                # 5. For tar - set executable PATH in environment with desktop shortcut (shortcut command??).
                echo "Package not found via apt-search."
        fi
        else
            echo "Package $name is already installed."
    fi
done