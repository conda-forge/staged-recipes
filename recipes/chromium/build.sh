#!/bin/bash
export TheBin="chrome"

if [ `uname` == "Darwin" ]; then
  export TheBin="Chromium.app/Contents/MacOS/Chromium"
fi

mkdir -p "$PREFIX/lib/chromium/"
cp "$PREFIX/*.*" "$PREFIX/lib/chromium/"
rm "$PREFIX/lib/chromium/conda_build.sh"
ln -s "$PREFIX/lib/chromium/$TheBin" "$PREFIX/bin/chrome"
