#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
cd source
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include
cp -v md5.h ${PREFIX}/include
if [ "$(uname)" == "Darwin" ]; then
${CC} md5.c -shared -fPIC -o libcms-md5.dylib
cp -v libcms-md5.dylib ${PREFIX}/lib
else
${CC} md5.c -shared -fPIC -o libcms-md5.so
cp -v libcms-md5.so ${PREFIX}/lib
fi
