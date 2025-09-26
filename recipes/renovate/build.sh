# #!/usr/bin/env bash
# set -o xtrace -o nounset -o pipefail -o errexit

# # Handle architecture differences
# if [[ "${target_platform}" == "osx-arm64" ]]; then
#     export npm_config_arch="arm64"
# fi

# # Make sure node from build env is available for cross-compiles
# if [[ "${build_platform}" != "${target_platform}" ]]; then
#     rm -f $PREFIX/bin/node || true
#     ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node
# fi

# # # Install dependencies
# # pnpm install --frozen-lockfile

# # # Build the project
# # pnpm run build

# # # Extract the package into $PREFIX/lib/renovate
# # # mkdir -p $PREFIX/lib/renovate
# # # tar -xzf "$TARBALL" -C $PREFIX/lib/renovate --strip-components=1
# # # rm "$TARBALL"

# # cp -R dist/* $PREFIX/
# # cp -R node_modules/* $PREFIX/lib

# # echo "$PREFIX:"
# # ls -lh $PREFIX

# # Create CLI wrapper in $PREFIX/bin
# rm -rf $PREFIX/bin
# mkdir -p $PREFIX/bin
# # cat > $PREFIX/bin/renovate <<'EOF'
# # #!/usr/bin/bash
# # node $CONDA_PREFIX/renovate.js
# # EOF
# # chmod +x $PREFIX/bin/renovate

# # echo "PREFIX/bin"
# # ls -lh $PREFIX/bin

# # # Generate third-party license report
# # pnpm-licenses generate-disclaimer --prod --output-file=$SRC_DIR/third-party-licenses.txt

# export npm_config_build_from_source=true

# ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node

# NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

# # pnpm import
# pnpm install --frozen-lockfile
# # pnpm pack
# pnpm run build
# # npm install -g renovate-*-semantic-release.tgz

# echo "** INSTALL COMPLETE **"
# echo "ls -lh $PREFIX/bin"
# ls -lh $PREFIX/bin

# ls -lh

# cp -R dist/* $PREFIX/ || true
# cp -R node_modules/* $PREFIX/lib

# cat > $PREFIX/bin/renovate <<'EOF'
# #!/usr/bin/bash
# node $CONDA_PREFIX/renovate.js
# EOF
# chmod +x $PREFIX/bin/renovate

# pnpm-licenses generate-disclaimer --prod --output-file=$SRC_DIR/third-party-licenses.txt


#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm i
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    renovate-0.0.0-semantic-release.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/renovate << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\renovate %*
EOF