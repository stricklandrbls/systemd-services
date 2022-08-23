#!/bin/bash
#CONFDIR=/etc/mediabackup/
CONFDIR=./
HOLDINGDIR=/tmp/

if ! [ -e "${CONFDIR}"mediabackup.conf ]; then
   echo "No configuration file can be found at "${CONFDIR:-1}
   exit 1
fi

BACKUPS=$(awk -F ':' '{if($1 == "backup"){print $2":"$3":"$4}}' ${CONFDIR}/mediabackup.conf)
for item in $BACKUPS; do
    file=`echo ${item} | awk -F ':' '{print $1}'`
    if ! [ -e ${file} ]; then
        echo "${file} does not exist"
    else
        tarfile=`echo ${item} | awk -F ':' '{print $2}'`
        dest=`echo ${item} | awk -F ':' '{print $3}'`
        if [ -e ${HOLDINGDIR}${tarfile::-3} ]; then
            tar --append -f ${HOLDINGDIR}${tarfile::-3} ${file}
            echo "Appending ${file} to ${tarfile::-3}"
        else
            tar -cf ${HOLDINGDIR}${tarfile::-3} ${file}
            echo "Creating ${file} to ${tarfile::-3}"
        fi
    fi

    if [ -e ${dest} ]; then
        mv ${HOLDINGDIR}${tarfile::-3} ${dest}
    else
        echo "Destination ${dest} does not exist. Archives will sit in /tmp"
    fi
done

TIME=$(date | awk '{print $2,$3,$4}')
echo "Completed backup at: "${TIME}
