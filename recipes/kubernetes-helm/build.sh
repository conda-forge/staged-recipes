#!/usr/bin/env bash

make_goroot_read_only()
{
    find $PREFIX/go -type d -exec chmod 555 {} \;
}

build_unix()
{
    make bootstrap
    make build
}

make_goroot_read_only

case $(uname -s) in
    "Linux"|"Darwin")
        build_unix
        ;;
esac
