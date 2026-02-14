#!/bin/bash

# Queue processing script for Claude Code tasks
# Each line is treated as a complete prompt

QUEUE_FILE="${1:-queue-list.txt}"
MAX_RUNTIME=600  # 10 minutes in seconds

# Check if queue file provided
if [ -z "$1" ]; then
    echo "Usage: $0 <queue-file>"
    echo "Example: $0 queue-list.txt"
    exit 1
fi

if [ ! -f "$QUEUE_FILE" ]; then
    echo "Error: Queue file '$QUEUE_FILE' not found"
    exit 1
fi

# Process a single line
process_item() {
    local line="$1"

    # Skip empty lines
    [[ -z "$line" ]] && return 1

    echo "========================================"
    echo "[$(date '+%H:%M:%S')] Processing: $line"
    echo "========================================"

    # Start timing
    local start_time=$(date +%s)

    # Run Claude Code with /grow-tool prefix (non-interactive mode)
    claude -p --dangerously-skip-permissions "/grow-tool $line"

    local result=$?

    # End timing
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [ $result -eq 0 ]; then
        echo "✅ Completed (⏱️ ${duration}s)"
        return 0
    else
        echo "❌ Failed (exit: $result, ⏱️ ${duration}s)"
        return 1
    fi
}

# Main loop
main() {
    echo "=== Queue Processor Started ==="
    echo "Queue: $QUEUE_FILE"
    echo ""

    while true; do
        # Get first non-empty line
        local line=$(head -n 1 "$QUEUE_FILE" 2>/dev/null)

        if [ -z "$line" ]; then
            echo "✓ Queue empty, exiting..."
            break
        fi

        # Process item
        process_item "$line"

        # Remove first line
        tail -n +2 "$QUEUE_FILE" > "${QUEUE_FILE}.tmp"
        mv "${QUEUE_FILE}.tmp" "$QUEUE_FILE"
        echo ""
    done
}

main
