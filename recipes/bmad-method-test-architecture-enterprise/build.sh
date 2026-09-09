#!/usr/bin/env bash
set -euxo pipefail

if [ ! -d "src" ]; then
    echo "ERROR: src/ directory not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

SHARE="${PREFIX}/share/bmad-method-test-architecture-enterprise"
mkdir -p "${SHARE}"
cp -r src/agents "${SHARE}/"
cp -r src/workflows "${SHARE}/"
cp src/module-help.csv src/module.yaml "${SHARE}/"
cp -r .claude-plugin "${SHARE}/"
cp CHANGELOG.md LICENSE README.md "${SHARE}/"

# Node CLIs (upstream package.json "bin"). 1.20.0 first shipped a working
# tea-test-review; 1.25.0 added tea-fragment-selection-runner + tea-trace-runner.
# Vendor cli/ + production node_modules next to it so require() resolves.
npm install --omit=dev --ignore-scripts --no-audit --no-fund
cp -r cli "${SHARE}/"
cp -r node_modules "${SHARE}/"
# cli/lib/review-provenance.js (new in 1.25.0) does require('../../package.json')
# to stamp teaCliVersion, so the manifest must sit at the share/ root beside cli/.
cp package.json "${SHARE}/"
# node_modules/.bin holds symlinks that fail the noarch portability check.
find "${SHARE}/node_modules" -type d -name .bin -exec rm -rf {} +

mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/bmad_tea_install.py" "${PREFIX}/bin/bmad-tea-install"
chmod +x "${PREFIX}/bin/bmad-tea-install"

# One dirname-relative sh wrapper per upstream bin entry. Keep this list in
# lockstep with package.json "bin" on every version bump (CFE G110).
write_wrapper() {
    local bin_name="$1" target="$2"
    cat > "${PREFIX}/bin/${bin_name}" <<EOF
#!/usr/bin/env bash
HERE="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
exec node "\${HERE}/../share/bmad-method-test-architecture-enterprise/cli/${target}" "\$@"
EOF
    chmod +x "${PREFIX}/bin/${bin_name}"
}

write_wrapper tea-test-review test-review.js
write_wrapper tea-fragment-selection-runner fragment-selection-runner.js
write_wrapper tea-trace-runner trace-runner.js
