#!/usr/bin/env bash
#
## Michael J. Mattingly
#
## Provides CCID to CrowdStrike Falcon Sensor

set -eu -o pipefail

function apply_license() {
    local license="<CCID>"
    local path="/Applications/Falcon.app/Contents/Resources/falconctl"
    local output
    output=$("$path" license "$license" 2>&1) || true

    printf "$(date) | Applying license.\n"

    if [ $? -eq 0 ]; then
        printf "$(date) | The license was applied.\n"
        return 0
    else
        printf "$(date) | Failed to apply license. Output: $output\n"
        exit 1
    fi
}

function is_path() {
    printf "$(date) | Checking if $path path exists.\n"
    if [ -f "$path" ]; then
        printf "$(date) | The $path path exists.\n"
        return 0
    else
        printf "The $path path doesn't exist. The Falcon Sensor hasn't yet deployed.\n"
        return 1
    fi
}

# Create log directory, log file, and begin logging.
function log() {
    local scriptName="provide_ccid_to_falcon_sensor.sh"
    local logDir="/Library/Logs/Microsoft/IntuneScripts/$scriptName"
    local log="$logDir/$scriptName.log"

    # Create log directory if it doesn't exist.
    if [[ ! -d "$logDir" ]]; then
        printf "$(date) | Creating $logDir directory to store logs.\n"
        mkdir -p "$logDir" || { printf "$(date) | Failed to create $logDir directory.\n"; exit 1; }
        printf "$(date) | Created $logDir directory.\n"
    fi

    # Begin logging.
    printf "$(date) | Begin log.\n"
    exec &> >(tee -a "$log")
}

log

if is_path; then
    apply_license
    exit 0
else
    exit 1
fi