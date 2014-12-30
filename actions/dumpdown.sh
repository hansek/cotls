#!/bin/bash

ACTION_NAME="dumpdown"
ACTION_VERSION="2014-12-29"


modx() {
    DB_REMOTE_USER=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep \\$database_user | cut -d \' -f 2`
    DB_REMOTE_PASS=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep \\$database_password | cut -d \' -f 2`
    DB_REMOTE_NAME=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep \\$dbase | cut -d \' -f 2`

    # Evolution needs to trim backticks
    DB_REMOTE_NAME=${DB_REMOTE_NAME#\`} # trim backtick from start of string
    DB_REMOTE_NAME=${DB_REMOTE_NAME%\`} # trim backtick from end of string
}


drupal7() {
    DB_REMOTE_USER=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep "      'username' =>" | cut -d ">" -f 2 | cut -d "'" -f 2`
    DB_REMOTE_PASS=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep "      'password' =>" | cut -d ">" -f 2 | cut -d "'" -f 2`
    DB_REMOTE_NAME=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep "      'database' =>" | cut -d ">" -f 2 | cut -d "'" -f 2`
}


wordpress() {
    DB_REMOTE_USER=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep DB_USER | cut -d \' -f 4`
    DB_REMOTE_PASS=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep DB_PASSWORD | cut -d \' -f 4`
    DB_REMOTE_NAME=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep DB_NAME | cut -d \' -f 4`
}


dumpdown() {
    checkSSHAccess

    # prepare exclude statments
    for i in "${!DB_REMOTE_IGNORED_TABLES[@]}"
    do
        DB_REMOTE_IGNORED_TABLES[i]="--ignore-table=${DB_REMOTE_NAME}.${DB_REMOTE_IGNORED_TABLES[i]}"
    done

    # get database config variables from config file for selected CMS/FW
    if [ ! -z "${PROJECT_CMS}" ] && [ ! -z "${PROJECT_SETTINGS_FILE}" ]
    then
        # check if parsing function for selected CMS/FW exists
        declare -f ${PROJECT_CMS} > /dev/null

        if [ $? -eq 1 ]
        then
            loge "Config parsing function for \"${PROJECT_CMS}\" not exists"
        fi

        log "Opening remote config file"

        if ssh -q ${SSH_USER}@${SSH_SERVER} [[ ! -f "${PROJECT_SETTINGS_FILE}" ]]
        then
            loge "Config file not found in location \"${PROJECT_SETTINGS_FILE}\""
        fi

        log "Loading remote database credentials"

        # execute parsing function
        ${PROJECT_CMS}

        # debug print parsed variables
        # echo $DB_REMOTE_NAME $DB_REMOTE_USER $DB_REMOTE_PASS
        # exit

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
