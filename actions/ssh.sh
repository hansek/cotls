#!/bin/bash

ACTION_NAME="ssh"
ACTION_VERSION="2014-12-24"

ssh() {
    log "Running SSH command: $SSH_COMMAND"

    ssh ${SSH_USER}@${SSH_SERVER} "${SSH_COMMAND}"

    return $?

    return 0
}
