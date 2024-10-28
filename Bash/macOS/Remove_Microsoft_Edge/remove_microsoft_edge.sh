#!/usr/bin/env bash
#
## Michael J. Mattingly
#
## Removes the Microsoft Edge app for macOS.

set -eu -o pipefail

# User-defined variables
files=(
    "/Applications/Microsoft Edge.app"
    "/Library/Application Support/Microsoft Edge"
    "/Library/Caches/Microsoft Edge"
    "/Library/WebKit/com.microsoft.edgemac"
    "/Library/Preferences/com.microsoft.edgemac.plist"
)
scriptName="remove_microsoft_edge.sh"
logDir="/Library/Logs/Microsoft/IntuneScripts/$scriptName"

# Generated variables
log="$logDir/$scriptName.log"

function is_file() {
    printf "$(date) | Checking if file exists.\n"
    if [ -d "$file" ] || [ -f "$file" ]; then
        printf "$(date) | The $file file exists and will be removed.\n"
        return 0
    elif [ ! -d "$file" ] || [ ! -f "$file" ]; then
        printf "The $file file doesn't exist.\n"
        return 1
    else
        printf "$(date) | Unable to determine whether or the the $file file exists.\n"
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

function remove_file() {
    printf "$(date) | Removing $file file.\n"
    rm -rf "$file"
    printf "$(date) | The $file file was removed.\n"
}

log

for file in "${files[@]}"; do
    if is_file; then
        remove_file
    else
        exit 0
    fi
done