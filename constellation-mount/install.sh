#!/bin/bash

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
    echo -e "[.] ${1}"
}
function display_help() {
    echo -e "SCE (SmartChain Encryptor) - Proprietary encryption script
    usage: \$0 (opt) <file>

Options:
    -a  = Archive unencrypted file. Set SC_ARCHIVE_DIR env var to redirect from default \$HOME/.scencrypt/archive
    -v  = Verbose output"
}

####################################################################################
# VARIABLE DEFINITIONS
####################################################################################
DIR_CONSTELLATION=".constellation"
DIR_HOME=`env | grep HOME | sed -e 's|HOME=||'`
DIR_UID=0
DIR_GID=0

declare -A DIR_MNT_POINTS
declare -A DIR_BETELGUESE_MNTS
declare -A SYS_INFO
DIR_MNT_POINTS[betelguese]="$DIR_HOME/$DIR_CONSTELLATION/betelguese/mnts/"
DIR_MNT_POINTS[bellatrix]="$DIR_HOME/$DIR_CONSTELLATION/bellatrix/mnts/"

DIR_SERVER_ROOT="/srv"

DIR_BETELGUESE_MNTS[media]="$DIR_MNT_POINTS[betelguese]/Media"

DIR_BELLATRIX_MNTS[files]="$DIR_MNT_POINTS[bellatrix]/Files"
DIR_BELLATRIX_MNTS[photos]="$DIR_MNT_POINTS[bellatrix]/Photos"
DIR_BELLATRIX_MNTS[books]="$DIR_MNT_POINTS[bellatrix]/Books"
####################################################################################
# FUNCTION DEFINITIONS
####################################################################################
function setup_install() {
  sys_info

  for dir in ${DIR_BELLATRIX_MNTS[@]}; do
    [[ ! -e "$dir" ]] && { mkdir -p "$dir" ; chown $DIR_UID:$DIR_GID "$dir" ; chmod 750 "$dir" ; }
    [[ ! -d "$dir" ]] && { warn "Omitting [$dir] - Not a directory" ; }
  done

  for dir in ${DIR_BETELGUESE_MNTS}; do
    [[ ! -e "$dir" ]] && { mkdir -p "$dir" ; chown $DIR_UID:$DIR_GID "$dir" ; chmod 750 "$dir" ; }
    [[ ! -d "$dir" ]] && { warn "Omitting [$dir] - Not a directory" ; }
  done
}

function home_dir() {
  [[ ${#DIR_HOME} -eq 0 ]] && DIR_HOME="/tmp/"
  DIR_UID=`stat -c %u $DIR_HOME`
  DIR_GID=`stat -c %g $DIR_HOME`

  echo "$DIR_UID"
  echo "$DIR_HOME"
}

function mnt_points() {
  echo "${DIR_BELLATRIX_MNTS[@]}"
  echo "${DIR_BETELGUESE_MNTS[@]}"
}

function setup_variables() {
  home_dir
  mnt_points
}

function sys_info() {
  SYS_INFO[os]=`uname -o`
  SYS_INFO[kernel]=`uname -s`
  SYS_INFO[hostname]=`uname -n`
  SYS_INFO[arch]=`uname -m`
  SYS_INFO[version]=`uname -v | awk '{print $1}'`

  for item in ${SYS_INFO[@]}; do
    info "${item}"
  done

  #echo "${SYS_INFO[@]}"
}

####################################################################################
# MAIN SCRIPT START
####################################################################################
# [[ ! $EUID -eq 0 ]] && { echo "Installation requires admin privileges." ; exit 1 ; }
setup_variables
setup_install

exit 0