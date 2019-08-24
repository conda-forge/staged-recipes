#!/bin/bash

mkdir -p ${PREFIX}/bin

if [ $(uname) == Linux ]; then
        mv * ${PREFIX}/bin
fi

if [ $(uname) == Darwin ]; then
  pkgutil --expand firefox.pkg firefox
  cpio -i -I firefox/Payload
  cp -rf Firefox.app $PREFIX/
  APP=$PREFIX/bin/firefox
  cat <<EOF >$APP
  #!/bin/bash
  $PREFIX/Firefox.app/Contents/MacOS/firefox "\$@"
  EOF
  chmod +x $APP
fi
