#!/bin/bash
openfonts="$PREFIX/fonts/open-fonts"
mkdir -p "$openfonts" || exit 1

mv css "$openfonts/" || exit 1
mv LICENSE "$openfonts/" || exit 1
mv fonts/* "$openfonts/" || exit 1
