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

CONFIG_SUFFIX=
DEFAULT_CONFIG_NAME=".cotls"

# help message
usage() {
    echo "Cotls - Condensed Tools [ 2014-12-24 ]"
    echo ""
    echo "Commands:"
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

# check arguments
if [ $# -le 0 ]
then
    usage
    exit 1
fi

# prepare arguments
for i in "$@"
do
    case $i in
        # allowed actions
        batch|dumpdown|syncdown|import)
            ACTION=$i

            case ${ACTION} in
                batch)
                    if [[ "$#" != 2 ]]; then
                        loge "Batch name not specified!"
                    fi

                    BATCH_NAME=$2
                ;;


                import)
                    if [[ "$#" != 2 ]]; then
                        loge "File to import not specified!"
                    fi

                    FILE_TO_IMPORT=$2
                    DB_LOCAL_NAME=$3
                    DB_LOCAL_USER=$4
                ;;
            esac

            shift
        ;;


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

# load config data
source ${CONFIG_FILE}


###############################################################################
# MAIN CODE

case ${ACTION} in

    batch)
        BATCH_VAR="BATCH_${BATCH_NAME^^}"
        BATCH_ARRAY="${BATCH_VAR}[@]"

        if [ -z ${!BATCH_ARRAY+x} ]
        then
            loge "Batch variable \"${BATCH_VAR}\" not found in config file!"
        fi

        for i in "${!BATCH_ARRAY}"
        do
            log "Running: \"cotls ${i}\""
            
            # run command
            $0 ${i}
        done
    ;;


    dumpdown)
        TARGET_FILENAME=${DB_REMOTE_NAME}${CONFIG_SUFFIX}.sql.gz

        # prepare exclude statments
        for i in "${!DB_REMOTE_IGNORED_TABLES[@]}"
        do
            DB_REMOTE_IGNORED_TABLES[i]="--ignore-table=${DB_REMOTE_NAME}.${DB_REMOTE_IGNORED_TABLES[i]}"
        done

        log "Dumping database ..."
        ssh ${SSH_USER}@${SSH_SERVER} "mysqldump -u ${DB_REMOTE_USER} -p${DB_REMOTE_PASS} ${DB_REMOTE_IGNORED_TABLES[@]} ${DB_REMOTE_PARAMETERS[@]} ${DB_REMOTE_NAME} | gzip -c" > ${TARGET_FILENAME}

        logs "Done, saved as \"${TARGET_FILENAME}\""
    ;;


    syncdown)

        # prepare exclude statments
        for i in "${!RSYNC_EXCLUDE_PATHS[@]}"
        do
            RSYNC_EXCLUDE_PATHS[i]="--exclude=${RSYNC_EXCLUDE_PATHS[i]}"
        done

        # iterate over paths from config
        for r_path in ${RSYNC_REMOTE_PATHS[*]}
        do
            log "Syncing remote \e[37;44m${r_path}\e[0m path to local path \e[37;44m$1${r_path}\e[0m"

            rsync -rzvt --delete --perms --chmod=a+rwx "${RSYNC_EXCLUDE_PATHS[@]}" "${RSYNC_PARAMETERS[@]}" -e ssh ${SSH_USER}@${SSH_SERVER}:${RSYNC_REMOTE_ROOT_PATH}${r_path}/ ${RSYNC_LOCAL_ROOT_PATH}${r_path}

            logs "Syncing remote \e[37;44m${r_path}\e[0m path finished"
        done
    ;;


    import)
        PASWORD=""

        if [ ! -z ${DB_LOCAL_PASS+x} ]
        then
            PASSWORD="${PASSWORD}"
        fi

        log "Importing file \e[37;44m${FILE_TO_IMPORT}\e[0m into database \e[37;44m${DB_LOCAL_NAME}\e[0m"

        # zip archive
        if [[ ${FILE_TO_IMPORT} == *.zip ]]
        then
            unzip -p ${FILE_TO_IMPORT} | mysql -u ${DB_LOCAL_USER} ${DB_LOCAL_NAME}

        # gzip archive
        elif [[ ${FILE_TO_IMPORT} == *.gz ]]; then
            gunzip < ${FILE_TO_IMPORT} | mysql -u ${DB_LOCAL_USER} ${PASSWORD} ${DB_LOCAL_NAME}

        # raw sql
        else
            mysql -u ${DB_LOCAL_USER} ${PASSWORD} ${DB_LOCAL_NAME} < ${FILE_TO_IMPORT}
        fi

        logs "Import probably finished"
    ;;


    *)
        loge "No valid command specified."
        echo ""
        usage
    ;;
esac

echo ""
