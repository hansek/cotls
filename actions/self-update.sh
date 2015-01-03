#!/bin/bash

ACTION_NAME="self-update"
ACTION_VERSION="2015-01-03"

self-update() {
    log "Geting latest changes from GitHub"

    cd ${COTLS_DIR}

    # check if is GIT root
    if [[ ! -d "${COTLS_DIR}/.git" ]]
    then
        loge "Not a GIT repository"
    fi

    if [ "$(git status --porcelain | wc -l)" -ne 0 ]
    then
        loge "COTLS repository is not clean, please clean it manually"
    fi

    log $(git fetch origin master)

    log $(git reset --hard origin/master)

    logs "COTLS updated successfully"
}
