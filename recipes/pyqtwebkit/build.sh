#!/bin/bash

set -e # Abort on error.

# Avoid Xcode
if [[ ${HOST} =~ .*darwin.* ]]; then
  PATH=${PREFIX}/bin/xc-avoidance:${PATH}
fi

# Dumb .. is this Qt or PyQt's fault? (or mine, more likely).
# The spec file could be bad, or PyQt could be missing the
# ability to set QMAKE_CXX
mkdir bin || true
pushd bin
  ln -s ${GXX} g++ || true
  ln -s ${GCC} gcc || true
popd
export PATH=${PWD}/bin:${PATH}

## START BUILD
$PYTHON configure.py \
        --verbose \
        --confirm-license \
        --assume-shared \
        --enable=QtWebKit \
        --enable=QtWebKitWidgets \
        --no-designer-plugin \
        --no-python-dbus \
        --no-qml-plugin \
        --no-qsci-api \
        --no-sip-files \
        --no-tools \
        -q ${PREFIX}/bin/qmake
make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

