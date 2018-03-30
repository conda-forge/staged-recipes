#!/usr/bin/env bash

make_goroot_read_only()
{
    find $PREFIX/go -type d -exec chmod 555 {} \;
}

build_linux()
{
    make fcp kubefed

    make test

    mv _output/bin/{fcp,kubefed} $PREFIX/bin

    pushd $PREFIX/bin
    ./fcp --make-symlinks
    popd
}

make_goroot_read_only

case $(uname -s) in
    "Linux")
        build_linux
        ;;
esac
