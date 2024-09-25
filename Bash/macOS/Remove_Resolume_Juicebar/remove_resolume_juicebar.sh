#!/usr/bin/env bash

## Michael J. Mattingly

## Removes the Resolume Juicebar app for macOS.

set -eu -o pipefail

# User-defined variables
dirs=("/Applications/Juicebar.app")
scriptName="remove_resolume_juicebar.sh"
logDir="/Library/Logs/Microsoft/IntuneScripts/$scriptName"

# Generated variables
log="$logDir/$scriptName.log"

function is_dir() {
    printf "$(date) | Checking if $dir directory exists.\n"
    if [ -d "$dir" ]; then
        printf "$(date) | The $dir directory exists and will be removed.\n"
        return 0
    elif [ ! -d "$dir" ]; then
        printf "The $dir directory doesn't exist.\n"
        return 1
    else
        printf "$(date) | Unable to determine whether or the the $dir directory exists.\n"
        exit 1
    fi
}

# Create log directory, log file, and begin logging.
function log() {
    # Create log directory if it doesn't exist.
    if [[ ! -d "$logDir" ]]; then
        printf "$(date) | Creating $logDir directory to store logs.\n"
        mkdir -p "$logDir"
        printf "$(date) | Created $logDir directory.\n"
    fi
    # Begin logging.
    printf "$(date) | Begin log.\n"
    exec &> >(tee -a "$log")
}

function remove_dir() {
    printf "$(date) | Removing $dir directory.\n"
    rm -rf "$dir"
    printf "$(date) | The $dir directory was removed.\n"
}

log

for dir in "${dirs[@]}"; do
    if is_dir; then
        remove_dir
    else
        exit 0
    fi
done