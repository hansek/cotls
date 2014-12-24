#!/bin/bash

ACTION_NAME="syncdown"
ACTION_VERSION="2014-12-24"

syncdown() {
    # prepare exclude statments
    for i in "${!RSYNC_EXCLUDE_PATHS[@]}"
    do
        RSYNC_EXCLUDE_PATHS[i]="--exclude=${RSYNC_EXCLUDE_PATHS[i]}"
    done

    # iterate over paths from config
    for r_path in ${RSYNC_REMOTE_PATHS[*]}
    do
        log "Syncing remote \e[37;44m${r_path}\e[0m path to local path \e[37;44m$1${r_path}\e[0m"

        rsync -rzvt --delete --perms --chmod=a+rwx "${RSYNC_EXCLUDE_PATHS[@]}" "${RSYNC_PARAMETERS[@]}" -e ssh ${SSH_USER}@${SSH_SERVER}:${RSYNC_REMOTE_ROOT_PATH}${r_path}/ ${RSYNC_LOCAL_ROOT_PATH}${r_path}

        logs "Syncing remote \e[37;44m${r_path}\e[0m path finished"
    done
}
