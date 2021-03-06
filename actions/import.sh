#!/usr/bin/env bash

ACTION_NAME="import"
ACTION_VERSION="2015-01-11"

import() {
    PASWORD=""

    # check if file exists

    if [ ! -f "$FILE_TO_IMPORT" ]; then
        loge "File \"${FILE_TO_IMPORT}\" not exists!"
    fi

    if [ ! -z "${DB_LOCAL_PASS+x}" ] && [ ! -z "${DB_LOCAL_PASS}" ]
    then
        PASSWORD="-p${DB_LOCAL_PASS}"
    fi

    log "Importing file \e[37;44m${FILE_TO_IMPORT}\e[0m into database \e[37;44m${DB_LOCAL_NAME}\e[0m"

    # zip archive
    if [[ ${FILE_TO_IMPORT} == *.zip ]]
    then
        unzip -p ${FILE_TO_IMPORT} | mysql -u ${DB_LOCAL_USER} ${PASSWORD} ${DB_LOCAL_NAME}

    # gzip archive
    elif [[ ${FILE_TO_IMPORT} == *.gz ]]; then
        gunzip < ${FILE_TO_IMPORT} | mysql -u ${DB_LOCAL_USER} ${PASSWORD} ${DB_LOCAL_NAME}

    # raw sql
    else
        mysql -u ${DB_LOCAL_USER} ${PASSWORD} ${DB_LOCAL_NAME} < ${FILE_TO_IMPORT}
    fi

    logs "Import probably finished"
}
