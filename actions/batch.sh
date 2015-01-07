#!/bin/bash

ACTION_NAME="batch"
ACTION_VERSION="2015-01-07"

batch() {
    BATCH_VAR="BATCH__${BATCH_NAME^^}"
    BATCH_ARRAY="${BATCH_VAR}[@]"

    if [ -z ${!BATCH_ARRAY+x} ]
    then
        loge "Batch variable \"${BATCH_VAR}\" not found in config file!"
    fi

    for i in "${!BATCH_ARRAY}"
    do
        log "Running: \"cotls ${i}\""

        # run command
        $0 ${i}
    done
}
