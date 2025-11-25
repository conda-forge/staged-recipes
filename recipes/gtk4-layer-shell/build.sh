#! /bin/bash

set -ex

meson setup -Dexamples=false -Ddocs=false -Dintrospection=false -Dvapi=false -Dsmoke-tests=false -Dtests=true -Dc_link_args='-ldl' --prefix=$PREFIX build
ninja -C build
ninja -C build install
ninja -C build test
ldconfig
