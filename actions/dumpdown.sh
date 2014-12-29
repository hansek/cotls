#!/bin/bash

ACTION_NAME="dumpdown"
ACTION_VERSION="2014-12-29"

MODX_CONFIG_PATH="config/config.inc.php"

dumpdown() {

    # prepare exclude statments
    for i in "${!DB_REMOTE_IGNORED_TABLES[@]}"
    do
        DB_REMOTE_IGNORED_TABLES[i]="--ignore-table=${DB_REMOTE_NAME}.${DB_REMOTE_IGNORED_TABLES[i]}"
    done

    if [ ! -z $REMOTE_MODX_CORE ]
    then
        log "Using Remote MODX CORE path \"$REMOTE_MODX_CORE\""

        if ssh -q ${SSH_USER}@${SSH_SERVER} [[ ! -f "${REMOTE_MODX_CORE}${MODX_CONFIG_PATH}" ]]
        then
            loge "MODX Revolution config.inc.php not found for remote CORE path \"${REMOTE_MODX_CORE}\""
        fi

        log "Loading remote database credentials from MODX Revolution config file"

        DB_REMOTE_USER=`ssh ${SSH_USER}@${SSH_SERVER} cat ${REMOTE_MODX_CORE}${MODX_CONFIG_PATH} | grep \\$database_user | cut -d \' -f 2`
        DB_REMOTE_PASS=`ssh ${SSH_USER}@${SSH_SERVER} cat ${REMOTE_MODX_CORE}${MODX_CONFIG_PATH} | grep \\$database_password | cut -d \' -f 2`
        DB_REMOTE_NAME=`ssh ${SSH_USER}@${SSH_SERVER} cat ${REMOTE_MODX_CORE}${MODX_CONFIG_PATH} | grep \\$dbase | cut -d \' -f 2`

        logs "Done, loading of credentials complete"
    fi

    # main variables validation
    if [ -z "${DB_REMOTE_USER}" ] || [ -z "${DB_REMOTE_PASS}" ] || [ -z "${DB_REMOTE_NAME}" ]
    then
        loge "At least one of username, password or database name of remote database is not set"
    fi

    TARGET_FILENAME=${DB_REMOTE_NAME}${CONFIG_SUFFIX}.$(date +"%Y-%m-%d-%H%M").sql.gz

    log "Dumping database \"${DB_REMOTE_NAME}\""
    ssh ${SSH_USER}@${SSH_SERVER} "mysqldump -u ${DB_REMOTE_USER} -p${DB_REMOTE_PASS} ${DB_REMOTE_IGNORED_TABLES[@]} ${DB_REMOTE_PARAMETERS[@]} ${DB_REMOTE_NAME} | gzip -c" > ${TARGET_FILENAME}

    logs "Done, saved as \"${TARGET_FILENAME}\""
}
