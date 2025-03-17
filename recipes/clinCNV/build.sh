#!/usr/bin/env bash
set -exo pipefail

# Copy all source files from SRC_DIR into the bin folder
mkdir -p "$PREFIX/bin/clincnv/"
cp -r "$SRC_DIR"/* "$PREFIX/bin/clincnv/"

# List of R script names
scripts=("clinCNV" "mergeFilesFromFolder" "generalHelpers" "mergeFilesFromFolderDT")

# Loop through each script name
for script in "${scripts[@]}"; do
  # Define the wrapper script path
  WRAPPER="$PREFIX/bin/${script}.R"
  
  # Create the wrapper script
  echo '#!/bin/bash' > "$WRAPPER"
  echo "Rscript \"\$PREFIX/bin/clincnv/${script}.R\" \"\$@\"" >> "$WRAPPER"
  
  # Make the wrapper and the original R script executable
  chmod +x "$WRAPPER"
  chmod +x "$PREFIX/bin/clincnv/${script}.R"
done
