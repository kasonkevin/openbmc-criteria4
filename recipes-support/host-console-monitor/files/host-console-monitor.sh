#!/bin/bash
LOG_FILE="/var/log/host-console.log"
PATTERN="Kernel panic"
LINES_BEFORE=2
LINES_AFTER=3

touch "$LOG_FILE"

BUFFER=()
ACTIVE_MATCH=""
AFTER_COUNT=0
MATCHED_CONTEXT=()

echo "🚀 開始監控 $LOG_FILE ..."
tail -n 0 -F "$LOG_FILE" | while read -r line; do
    [ -z "$line" ] && continue
    if [ "$ACTIVE_MATCH" = "true" ]; then
        MATCHED_CONTEXT+=("$line")
        ((AFTER_COUNT--))
        if [ "$AFTER_COUNT" -eq 0 ]; then
            CONTEXT_STR=$(printf '%s\\n' "${MATCHED_CONTEXT[@]}")
            
            # 👇 把 Rule 和 Context 直接拼接進 Message，字典設為空 (0)
            busctl call xyz.openbmc_project.Logging /xyz/openbmc_project/logging \
                xyz.openbmc_project.Logging.Create Create "ssa{ss}" \
                "HOST_PATTERN_MATCH|Rule=$PATTERN|Context=$CONTEXT_STR" \
                "xyz.openbmc_project.Logging.Entry.Level.Warning" \
                0
            
            ACTIVE_MATCH=""
            MATCHED_CONTEXT=()
        fi
    else
        if echo "$line" | grep -qiE "$PATTERN"; then
            ACTIVE_MATCH="true"
            MATCHED_CONTEXT=("${BUFFER[@]}" "$line")
            AFTER_COUNT=$LINES_AFTER
        else
            BUFFER+=("$line")
            if [ "${#BUFFER[@]}" -gt "$LINES_BEFORE" ]; then
                BUFFER=("${BUFFER[@]:1}")
            fi
        fi
    fi
done
