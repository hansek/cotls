#!/bin/bash

ACTION_NAME="self-update"
ACTION_VERSION="2015-01-07"

self-update() {
    log "Geting latest changes from GitHub"

    VERSION=$(version)
    log "Your version is ${VERSION}"

    cd ${COTLS_DIR}

    # check if is GIT root
    if [[ ! -d "${COTLS_DIR}/.git" ]]
    then
        loge "Not a GIT repository"
    fi

    if [ "$(git status --porcelain | wc -l)" -ne 0 ]
    then
        loge "Your local COTLS repository is not clean, please clean it manually, it's located in \"${COTLS_DIR}\""
    fi

    log "Fetching data from remote repository..."
    $(git fetch origin)

    COMMITS_COUNT=$(git rev-list HEAD...origin/master --count)

    if [ ${COMMITS_COUNT} -ne 0 ]
    then
        log "You're ${COMMITS_COUNT} behind release, updating..."

        log $(git reset --hard origin/master)
    else
        log "You're on latest commit"
    fi

    VERSION=$(version)
    log "Your version is ${VERSION}"

    logs "COTLS updated successfully"
}
