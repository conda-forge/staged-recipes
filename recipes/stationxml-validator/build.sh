#!/bin/bash
set -euxo pipefail

jar="stationxml-validator-${PKG_VERSION}.jar"
libdir="${PREFIX}/share/stationxml-validator"

# Install the upstream prebuilt fat jar (building from source is impossible in
# the network-less conda-forge sandbox; the jar bundles its Java dependencies,
# including stationxml-seed-converter).
mkdir -p "${libdir}"
cp "${SRC_DIR}/${jar}" "${libdir}/stationxml-validator.jar"

# Launcher that locates the jar relative to its own install location.
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/stationxml-validator" <<'EOF'
#!/bin/bash
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec java -jar "${root}/share/stationxml-validator/stationxml-validator.jar" "$@"
EOF
chmod +x "${PREFIX}/bin/stationxml-validator"

# Extract the third-party license/notice texts bundled inside the fat jar.
# conda-forge requires the license of every bundled component to be packaged.
cd "${SRC_DIR}"
unzip -p "${jar}" META-INF/LICENSE     > LICENSE-Apache-2.0.txt
unzip -p "${jar}" META-INF/LICENSE.txt > LICENSE-CDDL-1.1.txt
unzip -p "${jar}" META-INF/NOTICE      > NOTICE-jackson.txt
unzip -p "${jar}" META-INF/NOTICE.txt  > NOTICE-commons-csv.txt
unzip -p "${jar}" LICENSE-junit.txt    > LICENSE-EPL-1.0-junit.txt

# Licenses for bundled libs whose text is not embedded in the jar
# (system-rules = CPL-1.0; hamcrest = BSD-3-Clause); ship vendored copies.
cp "${RECIPE_DIR}/LICENSE-CPL-1.0.txt" .
cp "${RECIPE_DIR}/LICENSE-BSD-3-Clause-hamcrest.txt" .
