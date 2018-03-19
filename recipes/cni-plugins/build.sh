#!/usr/bin/env bash

make_goroot_read_only()
{
    find $PREFIX/go -type d -exec chmod 555 {} \;
}

build_linux()
{
    find -type f -exec sed -i'' "s|/etc/cni/net\.d|$PREFIX/etc/cni/net\.d|g" {} \;
    ./build.sh

    cp -avf bin/* $CNI_PATH
}

make_goroot_read_only

case $(uname -s) in
    "Linux")
        build_linux
        ;;
esac
