#!/bin/bash

APP_DIR=$PREFIX/bin/FirefoxApp
LAUNCH_SCRIPT=$PREFIX/bin/firefox

mkdir -p $APP_DIR

if [[ $(uname) == Linux ]]; then
  mv * $APP_DIR
  BIN_LOCATION=$APP_DIR/firefox
fi

# Write launch script and make executable
cat <<EOF >$LAUNCH_SCRIPT
#!/bin/bash
$BIN_LOCATION "\$@"
EOF
chmod +x $LAUNCH_SCRIPT
