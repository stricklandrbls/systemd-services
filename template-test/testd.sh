#!/bin/bash

if [ $EUID -ne 0 ]; then
    exit 254
fi

if [ $# -lt 2 ]; then
    exit 253
fi

case $1 in
    test )
        files=$(ls /run/sync/$2)
        if [[ $files == "" ]]; then 
            echo "Empty"
        else
            echo $files
        fi
    ;;
esac
