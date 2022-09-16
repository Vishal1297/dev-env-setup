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

# Take user input
read -p "Select your OS: " os

echo $os
echo $os_type
echo [[$os_type -eq "linux"]]

if [ $os == "1" ]; then
    # Check if os is linux
    if [[ $os_type -eq "linux" ]]; then
        echo "
###############################################################################
#                                                                             #
#                               Linux Setup                                   #
#                                                                             #
###############################################################################
"
        # Load variables
        source ./linux-script.sh
    fi
elif [ $os == "2" ]; then
    # Check if os is windows
    if [[ $os_type -eq "windows" ]]; then
        echo "
###############################################################################
#                                                                             #
#                               Windows Setup                                 #
#                                                                             #
###############################################################################
"
        # Load variables
        source ./windows-script.sh

    fi
else
    echo "Error: Invalid input"
    exit 1
fi
