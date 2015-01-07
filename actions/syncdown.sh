#!/bin/bash

ACTION_NAME="syncdown"
ACTION_VERSION="2015-01-07"

syncdown() {
    checkSSHAccess

    # prepare exclude statments
    for i in "${!RSYNC_EXCLUDE_PATHS[@]}"
    do
        RSYNC_EXCLUDE_PATHS[i]="--exclude=${RSYNC_EXCLUDE_PATHS[i]}"
    done

    # iterate over paths from config
    for r_path in ${RSYNC_REMOTE_PATHS[*]}
    do
        local RSYNC_EXCLUDES=()

        local EXCLUDE_VAR="RSYNC_EXCLUDE__${r_path^^}"
        local EXCLUDE_ARRAY="${EXCLUDE_VAR}[@]"

        local FORCE_VAR="RSYNC_FORCE_LOCAL__${r_path^^}"
        local FORCE_ARRAY="${FORCE_VAR}[@]"

        # prepare exclude statments
        for exclude in "${!EXCLUDE_ARRAY}"
        do
            RSYNC_EXCLUDES+=("--exclude=${exclude}")
        done

        # check local files, if exist add to exclude
        for item in "${!FORCE_ARRAY}"
        do
            if [ -f "${RSYNC_LOCAL_ROOT_PATH}${r_path}${item}" ]
            then
                log "Local file \"${item}\" will be skipped and not synced"
                RSYNC_EXCLUDES+=("--exclude=${item}")
            fi
        done

        log "Syncing remote \e[37;44m${r_path}\e[0m path to local path \e[37;44m$1${r_path}\e[0m"

        rsync -rzvt --delete --perms --chmod=a+rwx "${RSYNC_EXCLUDES[@]}" "${RSYNC_PARAMETERS[@]}" -e ssh ${SSH_USER}@${SSH_SERVER}:${RSYNC_REMOTE_ROOT_PATH}${r_path}/ ${RSYNC_LOCAL_ROOT_PATH}${r_path}

        logs "Syncing remote \e[37;44m${r_path}\e[0m path finished"
    done
}
