#!/usr/bin/env bash


GDKTARGET=""
if [ "$(uname)" == "Darwin" ];
then
    export GDKTARGET="quartz"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
elif [ "$(uname)" == "Linux" ];
then
    export GDKTARGET="x11"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath=${PREFIX}/lib"
fi


./configure \
    --prefix="${PREFIX}" \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --disable-glibtest \
    --enable-introspection=yes \
    --with-gdktarget="${GDKTARGET}" \
    --disable-visibility \
    --with-html-dir="${SRC_DIR}/html" \

make V=0 -j$CPU_COUNT
# make check -j$CPU_COUNT
make install -j$CPU_COUNT
