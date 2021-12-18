#!/bin/bash
# Backup system to rsyncnet
set -Eeuo pipefail

###############
# DEFINITIONS #
###############

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"

SOURCE_USER=remi

EXCLUDE_FILE="${SCRIPT_DIR}/rsync-exclude.txt"

# Base options
RSYNC_OPTIONS=( "-aHWx" "--numeric-ids" "--delete" "-M--fake-super" "--stats" "--exclude-from" "${EXCLUDE_FILE}" )

#########
# USAGE #
#########

usage() {
    echo "Usage: $(basename "${0}") [OPTIONS]

Backup system to rsyncnet.

OPTIONS:
    -n    Dry-run
    -v    Verbose
    -h    Display this message"
}

###################
# OPTIONS PARSING #
###################

while getopts 'nvh' opts ; do
    case "${opts}" in
        n)
            RSYNC_OPTIONS+=( "--dry-run" )
            ;;
        v)
            RSYNC_OPTIONS+=( "--verbose" )
            ;;
        h)
            usage
            exit 1
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done
shift "$((OPTIND - 1))"

#############
# FUNCTIONS #
#############

backUp() {
    local partition="${1}"
    local destination=""
    destination="$(hostname)/${partition#*/}"
    echo "Backing up ${partition} to ${destination} [$(date)]"
    rsync "${RSYNC_OPTIONS[@]}" "${partition}/" "truenas:${destination}"
}

###########
# ACTIONS #
###########

backUp /home/remi
