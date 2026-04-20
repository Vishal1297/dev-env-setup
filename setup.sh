#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create Menu
echo "
###############################################################################
#                                                                             #
#                               Setup Script                                  #
#                                                                             #
###############################################################################
"

# Show manual if manual.md exists
if [ -f "$SCRIPT_DIR/manual.md" ]; then
    echo "Showing manual (press q to continue)..."
    less "$SCRIPT_DIR/manual.md" 2>/dev/null || cat "$SCRIPT_DIR/manual.md"
fi

# Ask user to select the OS
echo "
###############################################################################
#                                                                             #
#                               Select OS                                     #
#                                                                             #
###############################################################################
"

echo "
1) Linux
2) Windows
"

# Detect OS type
case "$(uname -s)" in
    Linux*)  os_type="linux";;
    MINGW*|MSYS*|CYGWIN*) os_type="windows";;
    *)       os_type="unknown";;
esac

# Take user input
read -p "Select your OS: " os

if [ "$os" == "1" ]; then
    # Check if os is linux
    if [[ "$os_type" != "linux" ]]; then
        echo "Error: You selected Linux but this system is not Linux."
        exit 1
    fi
    # Check if user is root (required for Linux package installation)
    if [ "$(id -u)" != "0" ]; then
        echo "Error: You must be root to run this script, please use the root user to install the software."
        exit 1
    fi
    echo "
###############################################################################
#                                                                             #
#                               Linux Setup                                   #
#                                                                             #
###############################################################################
"
    # Load variables
    source "$SCRIPT_DIR/linux-script.sh"
elif [ "$os" == "2" ]; then
    # Check if os is windows
    if [[ "$os_type" != "windows" ]]; then
        echo "Error: You selected Windows but this system is not Windows."
        exit 1
    fi
    echo "
###############################################################################
#                                                                             #
#                               Windows Setup                                 #
#                                                                             #
###############################################################################
"
    # Load variables
    source "$SCRIPT_DIR/windows-script.sh"
else
    echo "Error: Invalid input"
    exit 1
fi
