#!/bin/bash

# This script provides the CCID (license) to the CrowdStrike Falcon Sensor.

# Provide license to sensor.
function apply_license() {
    local license
    license="<CCID>"
    local path
    path="/Applications/Falcon.app/Contents/Resources/falconctl"
    $path license $license
    return
}

# Verify whether or not sensor is licensed.
function is_licensed() {
    local error_machine_already_licensed
    error_machine_already_licensed="Error: This machine is already licensed"
    if [ $? -eq $error_machine_already_licensed ]; then
        echo "This machine is already licensed."
        true
    fi
    false
}

# Verify whether or not sensor is installed.
function is_present() {
    local file 
    file="/Applications/Falcon.app"
    if test -a $file; then
        echo "$file is present."
        true
    else
        echo "$file isn't present."
        false
    fi
}

if is_present; then
    apply_license
    if is_licensed; then
        exit 0
    fi
else
    exit 1
fi