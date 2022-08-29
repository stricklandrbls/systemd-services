#!/bin/bash

# Check if colored output is supported
CLR=0

ID=0
PATH_SOURCE="/"
ID_DIR=/run/sync

##################################################
# Terminal Output Formatting Functions
##################################################
cRedB="\e[01;31m"
cGreenB="\e[01;32m"
cYellowB="\e[01;33m"
cEnd="\e[00m"

function success(){
    echo -e "[${cGreeB}+${cEnd}] ${1}"
}
function warn(){
    echo -e "[${cYellowB}-${cEnd}] ${1}"
}
function err(){
    echo -e "[${cRedB}!${cEnd}] ${1}"
}
function info(){
    echo "[ ] ${1}"
}

if [ $EUID -ne 0 ]; then
    err "This command can only be run with elevated privileges!"
    exit 1
fi

function verify_arg(){
    case $1 in
        -al )
            # Check ID regex
            if ! [[ $ID =~ [a-zA-Z0-9]{1,} ]]; then
                err "Invalid ID. IDs must be alpha-numeric"
                exit 2
            fi
            # Check if path is absolute
            if ! [[ $PATH_SOURCE =~ ^[/].*[/].* ]]; then
                err "Path must be absolute, ie. start with \"/\" and outside of /"
                exit 2
            fi
            # Check if path leads to dir
            if [ -f $PATH_SOURCE ]; then
                err "Path must lead to a directory."
                exit 2
            fi
            # Check if ID already exists
            if [ -e /run/sync/$ID ]; then
                err "\tA syncing service with this ID already exists\n\tSee \"systemctl @${ID}.path for details"
                echo -e "\tDelete the service if you wish to continue with this ID."
                exit 2
            fi
        ;;
    esac
}

case $1 in
    -al )
        if [ $# -lt 3 ]; then
            err "Invalid number of arguments.\n\tOption '-h' displays help."
            exit 2
        fi
        ID=$2
        PATH_SOURCE=$3
        PATH_DEST="${4:-"/run/sync"}"/${ID}
        #PATH_DEST=/run/sync/${ID}
        verify_arg $1

        # Clear source variable
        PATH_SOURCE=`echo $PATH_SOURCE | sed -e 's./$..' -e 's.[//]./.g'`
        PATH_DEST=`echo $PATH_DEST | sed -e 's.[//]./.g' -e 's./$..'`
        #echo "${ID}: ${PATH_SOURCE}/${ID} ${PATH_DEST}"

        if ! [ -e $PATH_SOURCE ]; then
            mkdir -p ${PATH_SOURCE}/.logs
        fi
        if ! [ -e $PATH_DEST ]; then
            mkdir -p ${PATH_DEST}/.logs
        fi

        # These IDs are from stat and have a trailing '/'
        uid=`stat ${PATH_SOURCE} | awk '{if($3~/Uid/){print $5}}'`
        gid=`stat ${PATH_SOURCE} | awk '{if($7~/Gid/){print $9}}'`
        
        ln -s /run/sync/${ID} ${PATH_SOURCE}
        chown -R ${uid/\//}:${gid/\//} $PATH_SOURCE
        chmod 2755 $PATH_SOURCE 
        
        systemctl start test@${ID}.path
        
        ln -s ${PATH_DEST} /run/sync/${ID}/.out
        
        chown -R ${uid/\//}:${gid/\//} ${PATH_DEST}
        chown ${uid/\//}:${gid/\//} /run/sync/${ID}
        chmod 2755 ${PATH_DEST}

        systemctl enable test@${ID}.path

    ;;
    -dl )
        ID=$2
        systemctl stop test@${ID}.{path,service}
        rm -rf /run/sync/${ID} $3 
        systemctl daemon-reload
    ;;
esac 
