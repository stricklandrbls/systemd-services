#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo "This command can only be run with elevated privileges!"
    exit 1
fi

# Check if colored output is supported
CLR=0

ID=0
PATH_SOURCE="/"
ID_DIR=/run/sync

function verify_arg(){
    case $1 in
        -al )
            # Check ID regex
            if ! [[ $ID =~ [a-zA-Z0-9]{1,} ]]; then
                echo "Invalid ID. IDs must be alpha-numeric"
                exit 2
            fi
            # Check if path is absolute
            if ! [[ $PATH_SOURCE =~ ^[/].*[/].* ]]; then
                echo -e "Path must be absolute, ie. start with \"/\" and outside of /"
                exit 2
            fi
            # Check if path leads to dir
            if [ -f $PATH_SOURCE ]; then
                echo -e "Path must lead to a directory."
                exit 2
            fi
            # Check if ID already exists
            if [ -e i${ID_DIR}/$ID ]; then
                echo -e "A syncing service with this ID already exists\n\tSee \"systemctl @${ID}.path for details"
                echo -e "\tDelete the service if you wish to continue with this ID."
                exit 2
            fi
            
            # Clear source variable
            PATH_SOURCE=`echo $PATH_SOURCE | sed 's./$..'`

            if ! [ -e $PATH_SOURCE ]; then
                mkdir -p $PATH_SOURCE
            fi
            # These IDs are from stat and have a trailing '/'
            uid=`stat ${PATH_SOURCE} | awk '{if($3~/Uid/){print $5}}'`
            gid=`stat ${PATH_SOURCE} | awk '{if($7~/Gid/){print $9}}'`
            
            
            chown ${uid/\//}:${gid/\//} $PATH_SOURCE
            #echo -e "chown ${uid/\//}:${gid/\//} $PATH_SOURCE"
            systemctl start test@${ID}.path
            #echo "systemctl start test@${ID}.path"
            ln -s ${ID_DIR}/${ID} ${PATH_SOURCE}
            #echo "ln -s /run/sync/${ID} ${PATH_SOURCE}"
            chown ${uid/\//}:${gid/\//} ${ID_DIR}/${ID}
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
