#!/usr/bin/env bash

ACTION_NAME="dumpdown"
ACTION_VERSION="2015-05-19"


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


nette() {
    DB_REMOTE_USER=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep username: | cut -d " " -f 2 | HEAD -1`
    DB_REMOTE_PASS=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep password: | cut -d " " -f 2 | HEAD -1`
    DB_REMOTE_NAME=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep database: | cut -d " " -f 2 | HEAD -1`
}


prestashop() {
    DB_REMOTE_USER=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep "_DB_USER_" | cut -d "," -f 2 | cut -d \' -f 2`
    DB_REMOTE_PASS=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep "_DB_PASSWD_" | cut -d "," -f 2 | cut -d \' -f 2`
    DB_REMOTE_NAME=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep "_DB_NAME_" | cut -d "," -f 2 | cut -d \' -f 2`
}


radek() {
    DB_REMOTE_USER=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep \\$user_name | cut -d "\"" -f 2`
    DB_REMOTE_PASS=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep \\$password | cut -d "\"" -f 2`
    DB_REMOTE_NAME=`ssh ${SSH_USER}@${SSH_SERVER} cat ${PROJECT_SETTINGS_FILE} | grep \\$db_name | cut -d "\"" -f 2`
}


dumpdown() {
    checkSSHAccess

    # get database config variables from config file for selected CMS/FW
    if [ ! -z "${PROJECT_CMS+x}" ] && [ ! -z "${PROJECT_CMS}" ] && [ ! -z "${PROJECT_SETTINGS_FILE+x}" ] && [ ! -z "${PROJECT_SETTINGS_FILE}" ]
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

    # prepare exclude statments
    for i in "${!DB_REMOTE_IGNORED_TABLES[@]}"
    do
        DB_REMOTE_IGNORED_TABLES[$i]="--ignore-table=${DB_REMOTE_NAME}.${DB_REMOTE_IGNORED_TABLES[$i]}"
    done

    # if filename is set by argument
    if [ ! -z "${CUSTOM_TARGET_FILENAME+x}" ] && [ ! -z "${CUSTOM_TARGET_FILENAME}" ]
    then
        TARGET_FILENAME="${CUSTOM_TARGET_FILENAME}"
    fi

    # prepare final filename
    if [ -z "${TARGET_FILENAME}" ] && [ -z "${CUSTOM_TARGET_FILENAME}" ]
    then
        TARGET_FILENAME="${DB_REMOTE_NAME}${CONFIG_SUFFIX}.$(date +'%Y-%m-%d-%H%M').sql.gz"
    else
        # #date placeholder
        TARGET_FILENAME=$(sed -e "s/#date/$(date +'%Y-%m-%d')/g" <<< ${TARGET_FILENAME})
        # #time placeholder
        TARGET_FILENAME=$(sed -e "s/#time/$(date +'%H%M')/g" <<< ${TARGET_FILENAME})
        # #name placeholder
        TARGET_FILENAME=$(sed -e "s/#name/${DB_REMOTE_NAME}/g" <<< ${TARGET_FILENAME})
        # #suffix placeholder
        TARGET_FILENAME=$(sed -e "s/#suffix/${CONFIG_SUFFIX}/g" <<< ${TARGET_FILENAME})

        # add file extension
        TARGET_FILENAME="${TARGET_FILENAME}.sql.gz"
    fi

    # check if directory exists
    DIRECTORY=$(dirname "${TARGET_FILENAME}")

    if [ ! -d "$DIRECTORY" ]; then
        mkdir "$DIRECTORY"
    fi

    # dump
    log "Dumping database \"${DB_REMOTE_NAME}\""
    ssh ${SSH_USER}@${SSH_SERVER} "mysqldump -u ${DB_REMOTE_USER} -p${DB_REMOTE_PASS} ${DB_REMOTE_IGNORED_TABLES[@]} ${DB_REMOTE_PARAMETERS[@]} ${DB_REMOTE_NAME} | gzip -c" > ${TARGET_FILENAME}

    logs "Done, saved as \"${TARGET_FILENAME}\""
}
