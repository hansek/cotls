#!/bin/bash

ACTION_NAME="self-update"
ACTION_VERSION="2015-01-08"

self-update() {
    log "Geting latest changes from GitHub"

    # show current version
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

        RESPONSE=$(git reset --hard origin/master)
    else
        log "You're on latest commit"
    fi

    # check if user have the latest completion file
    OLD_COMPLETION_FILE="${SYSTEM_COMPLETION_DIR}${COTLS_ALIAS}"
    NEW_COMPLETION_FILE="${COTLS_DIR}/cotls_completion.sh"

    $(cmp --silent "${OLD_COMPLETION_FILE}" "${NEW_COMPLETION_FILE}")
    FILES_THE_SAME=$?

    if [ -d "${SYSTEM_COMPLETION_DIR}" ] && [ ! -f "${OLD_COMPLETION_FILE}" -o "${FILES_THE_SAME}" -ne 0 ]
    then
        log "Updating BASH completion file in: ${OLD_COMPLETION_FILE}"

        cp "${NEW_COMPLETION_FILE}" "${OLD_COMPLETION_FILE}"

        log "You should reload BASH completion file (execute \"source $OLD_COMPLETION_FILE\") to autocompletion work with latest version"
    fi

    # show current version
    VERSION=$(version)
    log "Your version is ${VERSION}"

    logs "COTLS updated successfully"
}
