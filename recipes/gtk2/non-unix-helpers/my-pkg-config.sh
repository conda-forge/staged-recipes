#!/bin/bash

# Path to the real pkg-config
REAL_PKG_CONFIG="$(which pkg-config.exe)"

# Log file to store debug output
LOG_FILE="${RECIPE_DIR}/pkg-config-debug.log"

# Log the arguments passed to pkg-config
echo "[$(date)] Arguments: $@" > "$LOG_FILE"

# Run the real pkg-config and capture output
OUTPUT=$("$REAL_PKG_CONFIG" "$@" 2>&1)

# Log the output from pkg-config
echo "[$(date)] Output: $OUTPUT" >> "$LOG_FILE"

# Print the output to stdout so calling tools work as expected
echo "$OUTPUT"

# Log environment variables like PKG_CONFIG_PATH for debugging
echo "[$(date)] PKG_CONFIG_PATH: $PKG_CONFIG_PATH" >> "$LOG_FILE"

# Exit with the same status as the real pkg-config
exit $?
