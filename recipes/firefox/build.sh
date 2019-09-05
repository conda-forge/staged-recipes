#!/bin/bash

APP=${PREFIX}/bin/firefox

if [[ $(uname) == Linux ]]; then
  mkdir -p ${PREFIX}/bin/Firefox
  mv * ${PREFIX}/bin/Firefox
  cat <<EOF >$APP
#!/bin/bash
$PREFIX/bin/Firefox/firefox "\$@"
EOF
elif [[ $(uname) == Darwin ]]; then
  pkgutil --expand firefox.pkg firefox
  cpio -i -I firefox/Payload
  cp -rf Firefox.app ${PREFIX}/
  cat <<EOF >$APP
#!/bin/bash
$PREFIX/Firefox.app/Contents/MacOS/firefox "\$@"
EOF
fi

chmod +x $APP
