#!/usr/bin/env bash

ACTION_NAME="rechmod"
ACTION_VERSION="2015-01-11"

CHMOD_DEFAULT_WRITE="777"

rechmod() {
    if [ -z "${CHMOD_PATHS_WRITE+x}" ] || [ -z "${CHMOD_PATHS_WRITE}" ]
    then
        loge "Paths for CHMOD not defined or is empty array"
    fi

    log "Setting defaults (755 / 644) to all project directories/files"

    # folders
    find ${PROJECT_LOCAL_ROOT} -type d -print0 | xargs -0 chmod 755
    # files
    find ${PROJECT_LOCAL_ROOT} -type f -print0 | xargs -0 chmod 644

    for LOCAL_PATH in "${CHMOD_PATHS_WRITE[@]}"
    do
        log "Chmoding ${CHMOD_DEFAULT_WRITE} to \"${LOCAL_PATH}\""

        chmod -R ${CHMOD_DEFAULT_WRITE} "${PROJECT_LOCAL_ROOT}${LOCAL_PATH}"
    done

    logs "Chmoding finished"
}
