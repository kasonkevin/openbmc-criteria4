#!/bin/bash
journalctl -f -n 0 | while read -r line; do
    if echo "$line" | grep -q "PAM password auth succeeded for"; then
        USER=$(echo "$line" | sed -E "s/.*succeeded for '([^']+)'.*/\1/")
        IP=$(echo "$line" | sed -E "s/.*from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/")
        echo "User $USER successfully logged in from IP $IP via SSH." | systemd-cat -t bmcweb -p info
    elif echo "$line" | grep -q "Bad PAM password attempt for"; then
        USER=$(echo "$line" | sed -E "s/.*attempt for '([^']+)'.*/\1/")
        IP=$(echo "$line" | sed -E "s/.*from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/")
        echo "User $USER failed to log in from IP $IP via SSH. Reason: Invalid Password" | systemd-cat -t bmcweb -p warning
    fi
done
