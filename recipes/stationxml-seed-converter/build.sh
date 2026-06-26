#!/bin/bash
set -euxo pipefail

jar="stationxml-seed-converter-${PKG_VERSION}.jar"
libdir="${PREFIX}/share/stationxml-seed-converter"

# Install the upstream prebuilt fat jar (built from source is impossible in the
# network-less conda-forge sandbox; the jar bundles its Java dependencies).
mkdir -p "${libdir}"
cp "${SRC_DIR}/${jar}" "${libdir}/stationxml-seed-converter.jar"

# Launcher that locates the jar relative to its own install location, so it
# works regardless of the final install prefix.
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/stationxml-seed-converter" <<'EOF'
#!/bin/bash
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec java -jar "${root}/share/stationxml-seed-converter/stationxml-seed-converter.jar" "$@"
EOF
chmod +x "${PREFIX}/bin/stationxml-seed-converter"

# Extract the third-party license/notice texts bundled inside the fat jar.
# conda-forge requires the license of every bundled component to be packaged;
# these are referenced from about.license_file in recipe.yaml.
cd "${SRC_DIR}"
unzip -p "${jar}" META-INF/LICENSE     > LICENSE-Apache-2.0.txt
unzip -p "${jar}" META-INF/LICENSE.txt > LICENSE-CDDL-1.1.txt
unzip -p "${jar}" META-INF/NOTICE      > NOTICE-jackson.txt

# system-rules (a stray test dep bundled in the jar) is CPL-1.0, whose text is
# not embedded in the jar; ship the canonical text vendored in the recipe.
cp "${RECIPE_DIR}/LICENSE-CPL-1.0.txt" .
