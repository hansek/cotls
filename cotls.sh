#!/usr/bin/env bash
# Copyright (c) 2015 Jan Tezner under the WTFPL license

# Condensed Tools for (Web) Developers
#
# INSTALL:
# - put script somewhere (home directory)
# - add execute permissoon
#   chmod +x ~/cotls.sh
# - make alias in your .bashrc 
#   alias cotls="~/cotls.sh"


###############################################################################
# MAIN VARIABLES

COTLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_SUFFIX=
ACTION_DIR="${COTLS_DIR}/actions/"
ACTION_SUFFIX=".sh"
DEFAULT_CONFIG_NAME=".cotls"


###############################################################################
# HELPER FUNCTIONS

# help message
usage() {
    echo "Cotls - Condensed Tools [ 2014-12-24 ]"
    echo ""
    echo "Actions:"
    echo "* batch - call cotls command sets"
    echo "* dumpdown - dump database from remote host to localhost"
    echo "* syncdown - rsync data from remote host to localhost"
    echo "* import - import dump file into database"
    echo "  Example: cotls import dump.sql dabatase_name database_user"
    echo ""
    echo "Arguments:"
    echo "* -c= | --config="
    echo "  Defile custom config file suffix, default blank"
    echo "* -prdb | --password-remote-db"
    echo "  Prompt user for password for remote DB"
}

log() {
    if [ -z "${2+x}" ]
    then
        COLOR="\e[33m"
    else 
        case "$2" in
            loge)
                COLOR="\e[31m"
            ;;

            success)
                COLOR="\e[32m"
            ;;

            *)
                COLOR="\e[33m"
            ;;
        esac
    fi

    echo -e "${COLOR}[$(date +"%Y-%m-%d %H:%M:%S")]\e[0m $1"
}

loge() {
    log "$1" "loge"
    echo ""
    exit 1
}

logs() {
    log "$1" "success"
}


###############################################################################
# ACTION CONTROL + VALIDATION

# check arguments
if [ $# -le 0 ]
then
    usage
    exit 1
fi

ACTION=$1

# chose a behavior depends on action name
case ${ACTION} in

    dumpdown|syncdown)
        # actions without defined routines or validations
    ;;


    batch)
        if [[ "$#" != 2 ]]; then
            loge "Batch name not specified!"
        fi

        BATCH_NAME=$2
    ;;


    ssh)
        if [[ "$#" != 2 ]]; then
            loge "SSH remote command not specified!"
        fi

        SSH_COMMAND=$2
    ;;


    import)
        if [[ "$#" != 2 ]]; then
            loge "File to import not specified!"
        fi

        FILE_TO_IMPORT=$2
        DB_LOCAL_NAME=$3
        DB_LOCAL_USER=$4
    ;;


    *)
        loge "Unknown command!"
    ;;
esac


###############################################################################
# ARGUMENTS CONTROL + VALIDATION

# prepare arguments
for i in "$@:2"
do
    case $i in

        # allowed arguments
        -c=*|--config=*)
            CUSTOM_CONFIG="${i#*=}"
            shift
        ;;


        -prdb|--password-remote-db)
            read -s -p "Enter Password for Remote DB: " DB_REMOTE_PASS
            echo ""
            shift
        ;;


        *)
            # unknown option
        ;;
    esac
done


###############################################################################
# CONFIG FILE ROUTINE

# prepare config file name
CONFIG_FILE="`pwd`/${DEFAULT_CONFIG_NAME}"

# check if custom config name
if [ ! -z ${CUSTOM_CONFIG+x} ]
then
    CONFIG_SUFFIX=".${CUSTOM_CONFIG}"
    CONFIG_FILE+=${CONFIG_SUFFIX}
fi

# check if config exists
if [ ! -f ${CONFIG_FILE} ]
then
    loge "Config file ${CONFIG_FILE} not found!"
    exit 1
fi

# load current config file data
source ${CONFIG_FILE}


###############################################################################
# MAIN ACTION CODE

ACTION_FILE="${ACTION_DIR}${ACTION}${ACTION_SUFFIX}"

# check if action file exists
if [ ! -f ${ACTION_FILE} ]
then
    loge "Action file \"${ACTION_FILE}\" not found!"
    exit 1
else
    source ${ACTION_FILE}

    # run selected action
    $ACTION

    # get return content from action function
    RETURN_VALUE=$?

    # TODO resolve RETURN_VALUE to success or error
fi

echo ""
