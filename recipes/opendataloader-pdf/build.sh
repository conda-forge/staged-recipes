#!/bin/bash
set -euxo pipefail

# Step 1: Build the Java JAR with Maven
cd "${SRC_DIR}/java"
mvn package -DskipTests -q

# Step 2: Pre-stage required files so hatchling's build hook skips the
# relative-path glob (../../java/...) and uses the "already exists" path
PKGDIR="${SRC_DIR}/python/opendataloader-pdf"
SRCPKG="${PKGDIR}/src/opendataloader_pdf"

mkdir -p "${SRCPKG}/jar"
cp "${SRC_DIR}/java/opendataloader-pdf-cli/target/opendataloader-pdf-cli-"*.jar "${SRCPKG}/jar/opendataloader-pdf-cli.jar"
cp "${SRC_DIR}/LICENSE" "${SRCPKG}/LICENSE"
cp "${SRC_DIR}/NOTICE" "${SRCPKG}/NOTICE"
cp "${SRC_DIR}/README.md" "${PKGDIR}/README.md"
cp -r "${SRC_DIR}/THIRD_PARTY" "${SRCPKG}/THIRD_PARTY"

# Step 3: Install the Python wrapper
cd "${PKGDIR}"
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
