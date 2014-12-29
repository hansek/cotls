#!/bin/bash

ACTION_NAME="fulldrop"
ACTION_VERSION="2014-12-29"

fulldrop() {
    PASWORD=""

    if [ ! -z ${DB_LOCAL_PASS+x} ]
    then
        PASSWORD="${PASSWORD}"
    fi

    log "Droping all tables from database \"${DB_LOCAL_NAME}\""

    DROP_TABLES_QUERY="
        SET FOREIGN_KEY_CHECKS = 0;
        SET GROUP_CONCAT_MAX_LEN=32768;
        SET @tables = NULL;

        SELECT GROUP_CONCAT('\`', table_name, '\`') INTO @tables
        FROM information_schema.tables
        WHERE table_schema = (SELECT DATABASE());

        SELECT IFNULL(@tables,'dummy') INTO @tables;

        SET @tables = CONCAT('DROP TABLE IF EXISTS ', @tables);

        PREPARE stmt FROM @tables;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET FOREIGN_KEY_CHECKS = 1;
    "

    # TODO check if there was no mysql error
    RETURN=$(mysql -u ${DB_LOCAL_USER} ${PASSWORD} ${DB_LOCAL_NAME} -e "${DROP_TABLES_QUERY}")

    logs "Done, all tables in  \"${DB_LOCAL_NAME}\" dropped"
}
