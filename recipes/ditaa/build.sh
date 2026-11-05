#!/usr/bin/env bash
set -eux

# Copy additional license files into the source directory so that
# conda-build can package them via the license_file entries in meta.yaml
cp "${RECIPE_DIR}/GPL-3.0.txt" ./
cp "${RECIPE_DIR}/NOTICE" ./

# Build the uberjar using lein from the conda-forge leiningen package
lein uberjar

# Install the jar
JAR="ditaa-0.11.0-standalone.jar"
mkdir -p "${PREFIX}/lib"
cp "./target/${JAR}" "${PREFIX}/lib/ditaa.jar"

# Create the wrapper script using a relative path so it works regardless
# of where the conda environment is installed
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/ditaa" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec java -ea -jar "${SCRIPT_DIR}/../lib/ditaa.jar" "$@"
EOF
chmod +x "${PREFIX}/bin/ditaa"

# Install NOTICE for user reference
mkdir -p "${PREFIX}/share/ditaa"
cp "${RECIPE_DIR}/NOTICE" "${PREFIX}/share/ditaa/"
