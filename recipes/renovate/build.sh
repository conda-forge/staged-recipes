#!/usr/bin/env bash
set -o xtrace -o nounset -o pipefail -o errexit

# Handle architecture differences
if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi

# Make sure node from build env is available for cross-compiles
if [[ "${build_platform}" != "${target_platform}" ]]; then
    rm -f $PREFIX/bin/node || true
    ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node
fi

# Install dependencies
pnpm install --frozen-lockfile

# Build the project
pnpm run build

# Extract the package into $PREFIX/lib/renovate
# mkdir -p $PREFIX/lib/renovate
# tar -xzf "$TARBALL" -C $PREFIX/lib/renovate --strip-components=1
# rm "$TARBALL"

cp -R dist/* $PREFIX/

echo "$PREFIX:"
ls -lh $PREFIX

# Create CLI wrapper in $PREFIX/bin
mkdir -p $PREFIX/bin
cat > $PREFIX/bin/renovate <<'EOF'
#!/usr/bin/env node
require(process.env.CONDA_PREFIX + '/lib/renovate/dist/renovate.js')
EOF
chmod +x $PREFIX/bin/renovate

echo "PREFIX/bin"
ls -lh $PREFIX/bin

# Generate third-party license report
pnpm-licenses generate-disclaimer --prod --output-file=$SRC_DIR/third-party-licenses.txt

