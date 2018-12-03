
BINARY_FILE='chrome'
UNPACK_DIR='chrome-linux'
if [ `uname` == "Darwin" ]; then
    BINARY_FILE='Chromium.app/Contents/MacOS/Chromium'
    UNPACK_DIR='./chrome-mac'
fi
unzip "${UNPACK_DIR}.zip"

mkdir -p "$PREFIX/lib/chromium/"
cp -r $SRC_DIR/$UNPACK_DIR/* "$PREFIX/lib/chromium/"
# this does not work, since chrome things all the libraries are in the bin directory
# ln -s "$PREFIX/lib/chromium/$BINARY_FILE" "$PREFIX/bin/chrome "
# instead, we make a wraper script
echo '#!/bin/bash' > $PREFIX/bin/chrome
echo "$PREFIX/lib/chromium/$BINARY_FILE" '"$@"' >> $PREFIX/bin/chrome
chmod +x "${PREFIX}/bin/chrome"