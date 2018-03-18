#!/usr/bin/env bash

make_goroot_read_only()
{
    find $PREFIX/go -type d -exec chmod 555 {} \;
}

git_init()
{
    git init
    git config --local user.email "conda-forge@googlegroups.com"
    git config --local user.name "conda-forge"
    git add conda_build.sh
    git commit -m "conda build of $PKG_NAME-v$PKG_VERSION"
    git tag v${PKG_VERSION}
}

build_unix()
{
    ./build
    mv bin/* $PREFIX/bin
}

case $(uname -s) in
    "Linux"|"Darwin")
        make_goroot_read_only
        git_init
        build_unix
        ;;
    *)
        exit 1
        ;;
esac
