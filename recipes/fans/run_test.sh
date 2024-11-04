#!/bin/bash

# Define the path to the original JSON file
JSON_FILE="$SRC_DIR/test/input_files/test_LinearElastic.json"

# Define the path for the modified JSON file
MODIFIED_JSON_FILE="$SRC_DIR/test/input_files/test_LinearElastic_mod.json"

# Set the new value for ms_filename
NEW_MS_FILENAME="$SRC_DIR/test/microstructures/sphere32.h5"

# Use jq to create a modified copy of the JSON file
jq --arg new_filename "$NEW_MS_FILENAME" '.ms_filename = $new_filename' "$JSON_FILE" > "$MODIFIED_JSON_FILE"


# Run tests
mpiexec -n 2 FANS "$MODIFIED_JSON_FILE" $SRC_DIR/test/test_results.h5