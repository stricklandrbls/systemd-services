#!/bin/bash

if [ $EUID -ne 0 ]; then
    exit 254
fi

if [ $# -lt 2 ]; then
    exit 253
fi

ID=$2
DIR_ID=/run/sync/$ID

case $1 in
    test )
        files=$(ls /run/sync/$ID)
        if [[ $files == "" ]]; then 
            echo "Empty"
        else
            echo $files
        fi
    ;;
    sync )
       for file in `ls ${DIR_ID} | grep -v [.]out`; do
            uid=`stat ${DIR_ID}/${file} | awk '{if($3~/Uid/){print $5}}'`
            gid=`stat ${DIR_ID}/${file} | awk '{if($7~/Gid/){print $9}}'`

            mv ${DIR_ID}/$file ${DIR_ID}/.out/$file
            chown ${uid/\//}:${gid/\//} ${DIR_ID}/.out/$file 
       done
esac
