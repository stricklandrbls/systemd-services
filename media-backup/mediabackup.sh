#!/bin/bash
CONFDIR=/etc/mediabackupd
#CONFDIR=
HOLDINGDIR=/tmp/mediabackupd
LOGDIR=/etc/mediabackupd/logs

function log(){
    TIME=$(date | awk '{print $2,$3,$4}')
    echo "[${TIME}] " $1 >> ${LOGDIR}/log
}

function log_and_print(){
    log $1
    echo $1
}

function setup(){
    if ! [ -e "${LOGDIR}" ]; then
        mkdir -p ${LOGDIR}
    elif [ -e "${LOGDIR}log" ]; then
        filesize=`stat ${LOGDIR}/log | awk '{if($1 == "Size:"){print $2}}'`
        if [ ${#filesize} -gt 5 ]; then
            echo "Filesize exceeds limit [${filesize}]; Generating fresh logfile."
            logfiles=`ls ${LOGDIR}/log.*`
            mv ${LOGDIR}/log ${LOGDIR}/log.${#logfiles}
        fi
    fi

    if ! [ -e ${HOLDINGDIR} ]; then
        mkdir -p $HOLDINGDIR
    fi
}

if ! [ -e ${CONFDIR}/mediabackupd.conf ]; then
   echo "No configuration file can be found at "${CONFDIR}
   exit 1
fi

setup
log_and_print "Initiating backup."

BACKUPS=$(awk -F ':' '{if($1 == "backup"){print $2":"$3":"$4}}' ${CONFDIR}/mediabackupd.conf)
for item in $BACKUPS; do
    log "Parsing: ${item}"

    file=`echo ${item} | awk -F ':' '{print $1}'`

    if ! [ -e ${file} ]; then
        log "${file} does not exist!" 
    else
        tarfile=`echo ${item} | awk -F ':' '{print $2}'`
        dest=`echo ${item} | awk -F ':' '{print $3}'`

        if [ -e ${HOLDINGDIR}/${tarfile::-3} ]; then
            tar --append -f ${HOLDINGDIR}/${tarfile::-3} ${file}
            log "Appending ${file} to ${tarfile::-3}"
        else
            tar -cf ${HOLDINGDIR}/${tarfile::-3} ${file}
            log "Creating ${tarfile::-3} with ${file}"
        fi
    fi
done

tars=$(ls ${HOLDINGDIR}/*.tar)
if [ -e ${dest} ]; then
    final=${dest}
else
    final=${HOLDINGDIR}
fi

for compressable in $tars; do
    log "Compressing ${compressable} to ${final}"
    # ls prepends directory to filename, needs to replace with nothing.
    if [ -e ${final}/${compressable/${HOLDINGDIR}/}.xz ]; then
        rm -rf ${final}/${compressable/${HOLDINGDIR}}.xz
    fi
    xz -z ${final}/${compressable/${HOLDINGDIR}/}
done

log_and_print "Completed backup."
