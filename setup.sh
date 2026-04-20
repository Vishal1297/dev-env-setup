#!/bin/bash

# Create Menu
echo "
###############################################################################
#                                                                             #
#                               Setup Script                                  #
#                                                                             #
###############################################################################
"

# Show Manual on new page

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use the root user to install the software."
    exit 1
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
    if [[ "$os_type" == "linux" ]]; then
        echo "
###############################################################################
#                                                                             #
#                               Linux Setup                                   #
#                                                                             #
###############################################################################
"
        # Load variables
        source ./linux-script.sh
    else
        echo "Error: You selected Linux but this system is not Linux."
        exit 1
    fi
elif [ "$os" == "2" ]; then
    # Check if os is windows
    if [[ "$os_type" == "windows" ]]; then
        echo "
###############################################################################
#                                                                             #
#                               Windows Setup                                 #
#                                                                             #
###############################################################################
"
        # Load variables
        source ./windows-script.sh
    else
        echo "Error: You selected Windows but this system is not Windows."
        exit 1
    fi
else
    echo "Error: Invalid input"
    exit 1
fi
