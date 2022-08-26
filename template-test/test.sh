#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo "This command can only be run with elevated privileges!"
    exit 1
fi

# Check if colored output is supported
CLR=0

ID=0
PATH_SOURCE="/"

function verify_arg(){
    case $1 in
        -al | -dl )
            # Check if path is absolute
            if ! [[ $PATH_SOURCE =~ ^[/] ]]; then
                echo -e "Path must be absolute, ie. start with \"/\"".
                exit 2
            fi
            # Check if path leads to dir
            if ! [ -d $PATH_SOURCE ]; then
                echo -e "Path must lead to a directory."
                exit 2
            fi
            # Check if ID already exists
            if [ -e /run/sync/$ID ]; then
                echo -e "A syncing service with this ID already exists\n\tSee \"systemctl @${ID}.path for details"
                echo -e "\tDelete the service if you wish to continue with this ID."
                exit 2
            fi
            
            echo "systemctl start test@${ID}.path"
            echo "ln -s /run/sync/${ID} ${PATH_SOURCE}"
            echo "chown ${EUID}:${EUID}"
        ;;
    esac
}

case $1 in
    -al | -dl )
        if [ $# -ne 3 ]; then
            echo -e "Invalid number of arguments.\n\tOption '-h' displays help."
            exit 2
        fi
        ID=$2
        PATH_SOURCE=$3
        echo "${ID}: ${PATH_SOURCE}"
        verify_arg $1
    ;;
esac 
