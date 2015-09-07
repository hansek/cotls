#!/usr/bin/env bash

ACTION_NAME="batch"
ACTION_VERSION="2015-01-11"

batch() {
    BATCH_VAR="BATCH__${BATCH_NAME^^}"
    BATCH_ARRAY="${BATCH_VAR}[@]"

    # TODO update check to correctly check if not empty, now this syntax has problem with existing and not empty var
#    if [ -z "${!BATCH_ARRAY+x}" ] || [ -z "${!BATCH_ARRAY}" ]
    if [ -z "${!BATCH_ARRAY+x}" ]
    then
        loge "Batch variable \"${BATCH_VAR}\" not found in config file or is empty!"
    fi

    for i in "${!BATCH_ARRAY}"
    do
        log "Running: \"cotls ${i}\""

        # run command
        $0 ${i}

        if [ $? -eq 1 ]
        then
            echo ""
            loge "There is a issue with last command, before continue please fix the issue!"
        fi
    done
}
