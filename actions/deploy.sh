#!/usr/bin/env bash

ACTION_NAME="deploy"
ACTION_VERSION="2015-01-20"

deploy() {
    checkSSHAccess

    # check if is GIT root
    if ssh ${SSH_USER}@${SSH_SERVER} [[ ! -d "${PROJECT_REMOTE_GIT_ROOT}.git" ]]
    then
        loge "Not a GIT repository"
    fi

    log "Using path \"${PROJECT_REMOTE_GIT_ROOT}\""

    log "Repository exists"

    IS_DIRTY=0

    # Get number of files added to the index (but uncommitted)
    RESPONSE=$(ssh ${SSH_USER}@${SSH_SERVER} "(cd ${PROJECT_REMOTE_GIT_ROOT}; git diff-index --cached HEAD | grep \"^M\" | wc -l)")

    if [[ ${RESPONSE} -ne "0" ]]
    then
        IS_DIRTY=1

        loge "Repository contain uncomitted changes, please make your repository clean manually"
    else
        log "Repository is clean without uncommited changes"
    fi

    # Get number of tracked and changed files in working directory
    RESPONSE=$(ssh ${SSH_USER}@${SSH_SERVER} "(cd ${PROJECT_REMOTE_GIT_ROOT}; git diff-files | wc -l)")

    if [[ ${RESPONSE} -ne "0" ]]
    then
        IS_DIRTY=1

        loge "Repository contain changes on tracked files, please make your repository clean manually"
    else
        log "Repository is clean without tracked and changed files"
    fi

    # Get number of untracked files
    RESPONSE=$(ssh ${SSH_USER}@${SSH_SERVER} "(cd ${PROJECT_REMOTE_GIT_ROOT}; git ls-files --exclude-standard --others 2>/dev/null | wc -l)")

    if  [[ ${RESPONSE} -ne 0 ]]
    then
        IS_DIRTY=1

        loge "Repository contain untracked files, please make your repository clean manually"
    else
        log "Repository is clean without untracked files"
    fi

    # TODO check if no new commit here

    # exit if repository is dirty
    if [[ ${IS_DIRTY} -eq 1 ]]
    then
        echo ""
        exit 1
    fi

    local GIT_REMOTE=${PROJECT_REMOTE_GIT_BRANCH% *}

    log "Fetching from \"${GIT_REMOTE}\""
    ssh -A ${SSH_USER}@${SSH_SERVER} "(cd ${PROJECT_REMOTE_GIT_ROOT}; git fetch ${GIT_REMOTE})"

    # TODO check if there are changes after fetch

    log "Deploying latest commits from \"${PROJECT_REMOTE_GIT_BRANCH/ /\/}\""
    ssh -A ${SSH_USER}@${SSH_SERVER} "(cd ${PROJECT_REMOTE_GIT_ROOT}; git reset --hard ${PROJECT_REMOTE_GIT_BRANCH/ /\/})"

    logs "Deployed sucessfully"
}
