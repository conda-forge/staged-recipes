#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

openfonts="$PREFIX/fonts/open-fonts"
mkdir -p "$openfonts"
mv css "$openfonts/"
mv LICENSE "$openfonts/"
mv fonts/* "$openfonts/"
