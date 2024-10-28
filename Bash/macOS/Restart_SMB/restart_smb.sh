#!/usr/bin/env bash
#
## Michael J. Mattingly
#
## Restarts SMB.

set -eu -o pipefail

# User-defined variables
scriptName="restart_smb.sh"
logDir="/Library/Logs/Microsoft/IntuneScripts/$scriptName"

SMBD_PLIST_FILE="/System/Library/LaunchDaemons/com.apple.smbd.plist"
SYS_CONFIG_FILE="/Library/Preferences/SystemConfiguration/com.apple.smb.server.plist"

# Generated variables
log="$logDir/$scriptName.log"

load_plist_file() {
    printf "$(date) | Loading the $SMBD_PLIST_FILE file."
    sudo launchctl load -w $SMBD_PLIST_FILE
    printf "$(date) | The $SMBD_PLIST_FILE file was loaded."
}

# Create log directory, log file, and begin logging.
log() {
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

unload_plist_file() {
    printf "$(date) | Unloading the $SMBD_PLIST_FILE file."
    sudo launchctl unload -w $SMBD_PLIST_FILE
    printf "$(date) | The $SMBD_PLIST_FILE file was unloaded."
}

update_config_file() {
    printf "$(date) | Updating the $SYS_CONFIG_FILE file."
    sudo defaults write $SYS_CONFIG_FILE EnabledServices -array disk
    printf "$(date) | The $SMBD_PLIST_FILE file was updated."
}

log

unload_plist_file
load_plist_file
update_config_file