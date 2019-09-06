#!/bin/bash

APP_DIR=$PREFIX/bin/FirefoxApp
LAUNCH_SCRIPT=$PREFIX/bin/firefox

# 1) Extract the application into a directory under bin

mkdir -p $APP_DIR

if [[ $(uname) == Linux ]]; then
  mv * $APP_DIR
elif [[ $(uname) == Darwin ]]; then
  pkgutil --expand firefox.pkg firefox
  cpio -i -I firefox/Payload
  cp -rf Firefox.app/* $APP_DIR
fi

# 2) Make a launch script in bin

if [[ $(uname) == Linux ]]; then
  cat <<EOF >$LAUNCH_SCRIPT
#!/bin/bash
$APP_DIR/firefox "\$@"
EOF
elif [[ $(uname) == Darwin ]]; then
  cat <<EOF >$LAUNCH_SCRIPT
#!/bin/bash
$APP_DIR/Contents/MacOS/firefox "\$@"
EOF
fi

# Now we've made the launch script, make it executable
chmod +x $LAUNCH_SCRIPT
