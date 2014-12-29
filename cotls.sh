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
COTLS_VERSION="2014-12-29"

CONFIG_SUFFIX=
ACTION_DIR="${COTLS_DIR}/actions/"
ACTION_SUFFIX=".sh"
DEFAULT_CONFIG_NAME=".cotls"

ARGUMENTS=("$@")
ARGUMENTS_COUNT=${#ARGUMENTS[@]}


###############################################################################
# HELPER FUNCTIONS

# help message
usage() {
    echo "Cotls - Condensed Tools [ ${COTLS_VERSION} ]"
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


strindex() {
    x="${1%%$2*}"

    if [[ $x = $1 ]]
    then
        POS=-1
    else
        POS=${#x}
    fi

    echo $POS
}


prepareAction() {
    local ACTION=$1

    # chose a behavior depends on action name
    case ${ACTION} in

        dumpdown|syncdown)
            # actions without defined routines or validations
        ;;


        batch)
            if [[ $ARGUMENTS_COUNT != 2 ]]; then
                loge "Batch name not specified!"
            fi

            BATCH_NAME=${ARGUMENTS[1]}
        ;;


        ssh)
            if [[ $ARGUMENTS_COUNT != 2 ]]; then
                loge "SSH remote command not specified!"
            fi

            SSH_COMMAND=${ARGUMENTS[1]}
        ;;


        import)
            if [[ $ARGUMENTS_COUNT != 2 ]]; then
                loge "File to import not specified!"
            fi

            FILE_TO_IMPORT=${ARGUMENTS[1]}
            DB_LOCAL_NAME=${ARGUMENTS[2]}
            DB_LOCAL_USER=${ARGUMENTS[3]}
        ;;


        *)
            loge "Unknown command!"
        ;;
    esac

}


callAction() {
    local ACTION=$1

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
        local RETURN=$?

        # TODO resolve RETURN to success or error
    fi

    return $RETURN
}


###############################################################################
# ACTION CONTROL + VALIDATION

# check arguments
if [ $ARGUMENTS_COUNT -le 0 ]
then
    usage
    exit 1
fi

CLI_ACTION="${ARGUMENTS[0]}"

prepareAction ${CLI_ACTION}


###############################################################################
# ARGUMENTS CONTROL + VALIDATION

# prepare arguments
for i in "${ARGUMENTS[@]:1}"
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

        -modx|--modx|-modx=*|--modx=*)
            REMOTE_MODX_ROOT="./"

            RETURN=$(strindex $i "=")

            if [ $RETURN -ge 1 ]
            then
                REMOTE_MODX_ROOT="${i#*=}"
            fi

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
    loge "Config file \"${CONFIG_FILE}\" not found!"
    exit 1
fi

# load current config file data
source ${CONFIG_FILE}


###############################################################################
# MAIN ACTION CODE

callAction ${CLI_ACTION}

RETURN_VALUE=$?

# TODO resolve RETURN_VALUE to success or error

echo ""
