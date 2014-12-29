#!/bin/bash

ACTION_NAME="dumpdown"
ACTION_VERSION="2014-12-29"

dumpdown() {

    # prepare exclude statments
    for i in "${!DB_REMOTE_IGNORED_TABLES[@]}"
    do
        DB_REMOTE_IGNORED_TABLES[i]="--ignore-table=${DB_REMOTE_NAME}.${DB_REMOTE_IGNORED_TABLES[i]}"
    done

    if [ ! -z $REMOTE_MODX_ROOT ]
    then
        log "Using Remote MODX Root \"$REMOTE_MODX_ROOT\""

        DB_REMOTE_USER=`ssh ${SSH_USER}@${SSH_SERVER} cat ${REMOTE_MODX_ROOT}core/config/config.inc.php | grep \\$database_user | cut -d \' -f 2`
        DB_REMOTE_PASS=`ssh ${SSH_USER}@${SSH_SERVER} cat ${REMOTE_MODX_ROOT}core/config/config.inc.php | grep \\$database_password | cut -d \' -f 2`
        DB_REMOTE_NAME=`ssh ${SSH_USER}@${SSH_SERVER} cat ${REMOTE_MODX_ROOT}core/config/config.inc.php | grep \\$dbase | cut -d \' -f 2`
    fi

    TARGET_FILENAME=${DB_REMOTE_NAME}${CONFIG_SUFFIX}.$(date +"%Y-%m-%d-%H%M").sql.gz

    log "Dumping database ..."
    ssh ${SSH_USER}@${SSH_SERVER} "mysqldump -u ${DB_REMOTE_USER} -p${DB_REMOTE_PASS} ${DB_REMOTE_IGNORED_TABLES[@]} ${DB_REMOTE_PARAMETERS[@]} ${DB_REMOTE_NAME} | gzip -c" > ${TARGET_FILENAME}

    logs "Done, saved as \"${TARGET_FILENAME}\""
}
