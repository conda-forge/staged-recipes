#!/bin/bash

# 1) Extract the application into a directory under bin

mkdir -p $PREFIX/bin/Firefox

if [[ $(uname) == Linux ]]; then
  mv * $PREFIX/bin/Firefox/
elif [[ $(uname) == Darwin ]]; then
  pkgutil --expand firefox.pkg firefox
  cpio -i -I firefox/Payload
  cp -rf Firefox.app/* $PREFIX/bin/Firefox/
fi

# 2) Make a launch script in bin

LAUNCH_SCRIPT=$PREFIX/bin/firefox

if [[ $(uname) == Linux ]]; then
  cat <<EOF >$LAUNCH_SCRIPT
#!/bin/bash
$PREFIX/bin/Firefox/firefox "\$@"
EOF
elif [[ $(uname) == Darwin ]]; then
  cat <<EOF >$LAUNCH_SCRIPT
#!/bin/bash
$PREFIX/bin/Firefox/Contents/MacOS/firefox "\$@"
EOF
fi

# Now we've made the launch script, make it executable
chmod +x $LAUNCH_SCRIPT
