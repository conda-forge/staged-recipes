#!/usr/bin/env bash
set -eux

APP_DIR=$PREFIX/bin/KaleidoApp
LAUNCH_SCRIPT=$PREFIX/bin/kaleido
BIN_LOCATION=$APP_DIR/kaleido
mkdir -p $APP_DIR

# Copy everything to app directory
cp -r ./* $APP_DIR

# Clean up conda build files
rm -rf $APP_DIR/build_env_setup.sh
rm -rf $APP_DIR/conda_build.sh

# Write launch script and make executable
cat <<EOF >$LAUNCH_SCRIPT
#!/bin/bash
export FONTCONFIG_PATH=$PREFIX/etc/fonts
$BIN_LOCATION "\$@"
EOF

chmod +x $LAUNCH_SCRIPT
