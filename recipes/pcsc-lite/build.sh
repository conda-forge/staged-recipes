#!/bin/bash

export BUILD_OPTS="
    --disable-dependency-tracking
	--disable-silent-rules
    --prefix=$PREFIX
	--sysconfdir=$PREFIX/etc
	--disable-libsystemd
"

if [[ $target_platform =~ linux.* ]]; then
    export BUILD_OPTS="${BUILD_OPTS} --disable-libudev"
fi

./configure ${BUILD_OPTS}
make install -j${CPU_COUNT}