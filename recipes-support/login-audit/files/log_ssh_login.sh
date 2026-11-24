#!/bin/bash
USER_NAME="${PAM_USER:-unknown}"
REMOTE_HOST="${PAM_RHOST:-unknown}"
PAM_RETVAL="${PAM_RETVAL:-0}"
if [ "$PAM_RETVAL" -eq 0 ]; then
    echo "User $USER_NAME successfully logged in from IP $REMOTE_HOST via SSH." | systemd-cat -t sshd -p info
else
    REASON="Unknown Error"
    case $PAM_RETVAL in
        6|7) REASON="Invalid Password" ;;
        10)  REASON="User Not Found" ;;
        11|12) REASON="Account Locked or Expired" ;;
        *)   REASON="PAM Error ($PAM_RETVAL)" ;;
    esac
    echo "User $USER_NAME failed to log in from IP $REMOTE_HOST via SSH. Reason: $REASON" | systemd-cat -t sshd -p warning
fi
