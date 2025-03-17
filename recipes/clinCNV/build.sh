#!/usr/bin/env bash
set -exo pipefail

# On Unix-like systems, ensure that files have the correct line endings
if [[ "$(uname)" != "Windows_NT" ]]; then
  find "$SRC_DIR" -type f -exec dos2unix {} \;
fi

# Continue with copying files and creating wrappers as before
mkdir -p "$PREFIX/bin/clincnv/"
cp -r "$SRC_DIR"/* "$PREFIX/bin/clincnv/"

# List of R script names
scripts=("clinCNV" "mergeFilesFromFolder" "generalHelpers" "mergeFilesFromFolderDT")

# Loop through each script name
for script in "${scripts[@]}"; do
  WRAPPER="$PREFIX/bin/${script}"
  echo '#!/bin/bash' > "$WRAPPER"
  echo "Rscript \"\$PREFIX/bin/clincnv/${script}.R\" \"\$@\"" >> "$WRAPPER"
  chmod +x "$WRAPPER"
  chmod +x "$PREFIX/bin/clincnv/${script}.R"
done