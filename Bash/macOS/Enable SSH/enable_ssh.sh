#!/usr/bin/env bash

## Michael J. Mattingly

## Script enables the SSH service if it's disabled.

set -eu -o pipefail

# User-defined variables
scriptName="enable_ssh.sh"
logDir="/Library/Logs/Microsoft/IntuneScripts/$scriptName"

# Generated variables
log="$logDir/$scriptName.log"

# Turn on SSH service.
enable_ssh() {
    printf "$(date) | Enabling SSH service.\n"
    systemsetup -setremotelogin on
    printf "$(date) | Enabled SSH service.\n"
    exit 0
}

# Check if SSH service is off.
is_ssh_off?() {
    printf "$(date) | Checking if SSH service is on.\n"
    if systemsetup -getremotelogin | grep -q "On"; then
        printf "$(date) | SSH service is on.\n"
        exit 0
    elif systemsetup -getremotelogin | grep -q "Off"; then
        printf "$(date) | SSH service is off.\n"
        return true
    else
        printf "$(date) | Unable to determine if the SSH service is on or off.\n"
        exit 1
    fi  
}

# Create log directory, log file, and begin logging.
log() {
    # Create log directory if it doesn't exist.
    if [[ ! -d "$logDir" ]]; then
        printf "$(date) | Creating [$logDir] directory to store logs.\n"
        mkdir -p "$logDir"
        printf "$(date) | Created [$logDir] directory.\n"
    fi
    # Begin logging.
    printf "$(date) | Begin log.\n"
    exec &> >(tee -a "$log")
}

log

if is_ssh_off?; then
    enable_ssh
else
    exit 0
fi