#!/bin/bash

# This script enables the SSH service if it's disabled.

# Check if SSH service is off.
is_disabled() {
    if systemsetup -getremotelogin | grep -q "On"; then
        return
    fi

    true
}

# Turn on SSH service.
enable_ssh() {
    systemsetup -setremotelogin on
}

if is_disabled; then
    enable_ssh
else
    exit 0
fi