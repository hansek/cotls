#!/bin/bash
# Copyright (c) 2014 Jan Tezner under the MIT license

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

COTLS_ALIAS="cotls"
COTLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COTLS_VERSION="2015-05-15"
COTLS_HASH=

CONFIG_SUFFIX=
CONFIG_PATH=
ACTION_DIR="${COTLS_DIR}/actions/"
ACTION_SUFFIX=".sh"
DEFAULT_CONFIG_NAME=".cotls"

ARGUMENTS=("$@")
ARGUMENTS_COUNT=${#ARGUMENTS[@]}

PROJECT_CMS=
PROJECT_SETTINGS_FILE=

SYSTEM_COMPLETION_DIR="/etc/bash_completion.d/"

SKIP_CONFIG=0

DRY_RUN=false

###############################################################################
# HELPER FUNCTIONS

version() {
    # check if is GIT root
    if [[ -d "${COTLS_DIR}/.git" ]]
    then
        cd ${COTLS_DIR}

        COTLS_HASH=$(git rev-parse --short HEAD)
    fi

    if [ -n "${COTLS_HASH}" ]
    then
        COTLS_HASH=" #${COTLS_HASH}"
    fi

    echo "${COTLS_VERSION}${COTLS_HASH}"
}

# help message
usage() {
    # colors definition
    RST="\e[0m" # reset
    TIT="\e[32m" # title
    VAR="\e[33m" # variable
    VAL="\e[36m" # value
    HGL="\e[31m" # highlight

    echo -e "Cotls - Condensed Tools [ ${COTLS_VERSION} ]"

    echo -e ""

    echo -e "${TIT}Actions:${RST}"

    echo -e "${VAR}batch${RST} - call cotls command sets"
    echo -e "${VAR}dumpdown${RST} - dump database from remote host to localhost"
    echo -e "${VAR}syncdown${RST} - rsync data from remote host to localhost"
    echo -e "${VAR}import${RST} - import dump file into database"
    echo -e "   Example: cotls import dump.sql dabatase_name database_user"
    echo -e "${VAR}fulldrop${RST} - drop all tables for selected database in local mysql"
    echo -e "${VAR}deploy${RST} - make a GIT deploy on remote server"
    echo -e "${VAR}rechmod${RST} - apply file mode to defined directories/files"
    echo -e "${VAR}self-update${RST} - update COTLS it self from GIT"

    echo -e ""


    echo -e "${TIT}Arguments:${RST}"

    # -c=<config-suffix>
    echo -e "${VAR}-c=${RST}${VAL}<config-suffix>${RST}"
    echo -e "   Custom config file suffix, default blank (config file has name \"${DEFAULT_CONFIG_NAME}\") "
    echo -e "   E.g. value \"dev\" supposed to config file has name \"${DEFAULT_CONFIG_NAME}.dev\")"

    # -cp=<path-to-config-file>
    echo -e "${VAR}-cp=${RST}${VAL}<path-to-config-file>${RST}"
    echo -e "   Path can be relative or absolute, default value is current directory."

    # -prdb
    echo -e "${VAR}-prdb${RST}"
    echo -e "   Prompt user for password for remote DB"

    # -tf
    echo -e "${VAR}-tf=${RST}${VAL}<target-filename>${RST}"
    echo -e "   Target filename, can contain relative or absolute path"
    echo -e "   Placeholders:"
    echo -e "      ${VAL}#date${RST} - current date in mysql format (e.g. 2015-01-01)"
    echo -e "      ${VAL}#time${RST} - current time in hours and minutes (e.g. 1000)"
    echo -e "      ${VAL}#name${RST} - database name"
    echo -e "      ${VAL}#suffix${RST} - config suffix if defined"

    echo -e ""
}


log() {
    # colors definition
    RST="\e[0m" # reset
    SCS="\e[32m" # title
    DEF="\e[33m" # default
    ERR="\e[31m" # highlight
    DEP="\e[31m" # deprecated
    MSG=

    if [ -n "$1" ]
    then
        IN="$1"
    else
        read IN # This reads a string from stdin and stores it in a variable called IN
    fi

    if [ -z "${2+x}" ]
    then
        COLOR=${DEF}
    else 
        case "$2" in
            deprecated)
                COLOR=${DEP}
                MSG=${DEF}
            ;;

            error)
                COLOR=${ERR}
            ;;

            success)
                COLOR=${SCS}
            ;;

            *)
                COLOR=${DEF}
            ;;
        esac
    fi

    DATETIME=$(date +"%Y-%m-%d %H:%M:%S")

    echo -e "${COLOR}[${DATETIME}]${RST} ${MSG}${IN}"
}


loge() {
    log "$1" "error"

    if [ -z "${2+x}" ]
    then
        echo ""
        exit 1
    fi
}


logs() {
    log "$1" "success"
}


logd() {
    log "$1" "deprecated"
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

# http://stackoverflow.com/a/14367368
# usage array_contains ARRAY $SEEK
array_contains() {
    local array="$1[@]"
    local seeking=$2
    local in=0

    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=1
            break
        fi
    done

    return $in
}


prepareAction() {
    local ACTION=$1

    # chose a behavior depends on action name
    case ${ACTION} in

        dumpdown|syncdown|deploy|rechmod)
            # actions without defined routines or validations
        ;;


        fulldrop)
            # TODO pass user, pass, name from CLI
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


        self-update)
            SKIP_CONFIG=1
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


checkSSHAccess() {
    # main variables validation
    if [ -z "${SSH_USER}" ] || [ -z "${SSH_SERVER}" ]
    then
        loge "SSH user or server not defined, check your COTLS configuration file"
    fi

    # check if ssh agent is running and has a loaded key
    ssh-add -l >/dev/null 2>&1

    if [ $? = 2 ]
    then
        # exit-status 2 = couldn't connect to ssh-agent
        loge "SSH-AGENT not active, please start SSH-AGENT before continue!"
    fi

    # check if has access to remote server
    ssh -q ${SSH_USER}@${SSH_SERVER} exit

    if [ $? -ne 0 ]
    then
        loge "User don't have access to remote server over SSH"
    fi
}

###############################################################################
# ARGUMENTS CONTROL + VALIDATION

# prepare arguments
for i in "${ARGUMENTS[@]}"
do
    case $i in

        # allowed arguments
        -c=*)
            CUSTOM_CONFIG="${i#*=}"
            shift
        ;;


        -cp=*)
            CONFIG_PATH="${i#*=}"
        ;;


        -tf=*)
            CUSTOM_TARGET_FILENAME="${i#*=}"
        ;;


        -prdb)
            # TODO overide predefined value from config file
            read -s -p "Enter Password for Remote DB: " DB_REMOTE_PASS
            echo ""
            shift
        ;;


        -n)
            DRY_RUN=true
        ;;


        -v)
            version
            exit
        ;;


        *)
            # unknown option
        ;;
    esac
done


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
# CONFIG FILE ROUTINE

if [ ${SKIP_CONFIG} -eq 0 ]
then
    # prepare config file name
    CONFIG_FILE="${CONFIG_PATH}${DEFAULT_CONFIG_NAME}"

    # check if custom config name
    if [ ! -z "${CUSTOM_CONFIG+x}" ] && [ ! -z "${CUSTOM_CONFIG}" ]
    then
        CONFIG_SUFFIX=".${CUSTOM_CONFIG}"
        CONFIG_FILE+=${CONFIG_SUFFIX}

        log "Using custom config file \"${DEFAULT_CONFIG_NAME}.${CUSTOM_CONFIG}\""
    fi

    # check if config exists
    if [ ! -f ${CONFIG_FILE} ]
    then
        loge "Config file \"${CONFIG_FILE}\" not found!"
        exit 1
    fi

    # load current config file data
    source ${CONFIG_FILE}
fi


###############################################################################
# DEPRECATIONS

# TODO 2015-02-01 remove
if [ ! -z "${RSYNC_LOCAL_ROOT_PATH+x}" ]
then
    logd "DEPRECATED usage of \"RSYNC_LOCAL_ROOT_PATH\" in your config, please change variable name to \"PROJECT_LOCAL_ROOT\" (old will be removed on end of january)"

    if [ -z "${PROJECT_LOCAL_ROOT}" ]
    then
        logd "\"PROJECT_LOCAL_ROOT\" not defined, using value of \"RSYNC_LOCAL_ROOT_PATH\""

        PROJECT_LOCAL_ROOT="${RSYNC_LOCAL_ROOT_PATH}"
    fi

fi

###############################################################################
# MAIN ACTION CODE

callAction ${CLI_ACTION}

RETURN_VALUE=$?

# TODO resolve RETURN_VALUE to success or error

echo ""
