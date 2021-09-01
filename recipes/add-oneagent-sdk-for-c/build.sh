#!/bin/env bash

mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/include/onesdk"

cp -a "lib/linux-$(uname -m)/libonesdk_shared.so" "${PREFIX}/lib/libonesdk_shared.so"
cp -a "include/onesdk/." "${PREFIX}/include/onesdk"
