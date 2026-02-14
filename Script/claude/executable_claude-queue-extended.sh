#!/bin/bash

# Claude Code Extended Queue Processor
# Processes each line through multiple tools in sequence, passing output forward

# Check if queue file argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <queue-file>"
    echo "Example: $0 queue-list-extended.txt"
    exit 1
fi

QUEUE_FILE="$1"
TOOLS=("/tool-creator" "/tool-translator" "/tool-tester" "/tool-validator")

echo "=== Extended Queue Processor Started ==="
echo "Queue: $QUEUE_FILE"
echo "Tools: ${TOOLS[@]}"
echo ""

# Check if queue file exists
if [ ! -f "$QUEUE_FILE" ]; then
    echo "❌ Queue file not found: $QUEUE_FILE"
    exit 1
fi

while true; do
    # Read first line
    line=$(head -n 1 "$QUEUE_FILE")

    # Check if empty
    if [ -z "$line" ]; then
        echo "✓ Queue empty, exiting..."
        break
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Processing: $line"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Start timing
    start_time=$(date +%s)

    # Initialize with original prompt
    accumulated_output=""
    current_prompt="$line"

    # Process through each tool in sequence
    for tool in "${TOOLS[@]}"; do
        echo ""
        echo "▶ Running: $tool"
        echo "   Input: ${current_prompt:0:100}..."
        echo ""

        # Start tool timing
        tool_start=$(date +%s)

        # Run Claude with the tool, show output AND capture it
        result=$(claude -p --dangerously-skip-permissions "$tool just finish your job , noneed any interactive question,  $current_prompt" 2>&1 | tee /dev/tty)

        # End tool timing
        tool_end=$(date +%s)
        tool_duration=$((tool_end - tool_start))

        # Accumulate ALL outputs
        accumulated_output="$accumulated_output

--- Previous output from $tool ---
$result"

        # Next prompt = original + ALL accumulated outputs
        current_prompt="$line

$accumulated_output"

        echo ""
        echo "   ✓ Completed (⏱️ ${tool_duration}s)"
    done

    # End timing
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    echo ""
    echo "✓ All tools completed for: $line"
    echo "⏱️  Total time taken: ${duration}s"
    echo ""

    # Remove processed line
    sed -i '' '1d' "$QUEUE_FILE"

    # Optional: small delay between items
    sleep 1
done

echo "=== Extended Queue Processor Finished ==="
