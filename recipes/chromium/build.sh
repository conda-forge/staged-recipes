#!/bin/bash
export TheBin="chrome"

if [ `uname` == "Darwin" ]; then
  export TheBin="Chromium.app/Contents/MacOS/Chromium"
fi

mkdir -p "$PREFIX/lib/chromium/"
cp -r $SRC_DIR/* "$PREFIX/lib/chromium/"
rm "$PREFIX/lib/chromium/conda_build.sh"

echo '#!/bin/bash' > $PREFIX/bin/chrome
echo $PREFIX/lib/chromium/$TheBin '"$@"' >> $PREFIX/bin/chrome
chmod +x "${PREFIX}/bin/chrome"
