#!/usr/bin/env bash

go_init()
{
    export GOPATH=$(pwd)/gopath

    ORG_PATH="github.com/coredns"
    REPO_PATH="${ORG_PATH}/${PKG_NAME}"

    if [ ! -h gopath/src/${REPO_PATH} ]; then
        mkdir -p gopath/src/${ORG_PATH}
        ln -s ../../../.. gopath/src/${REPO_PATH} || exit 255
    fi

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
    cd gopath/src/${ORG_PATH}/${PKG_NAME}
    make CHECKS= godeps all

    cp coredns $PREFIX/bin
}

case $(uname -s) in
    "Linux"|"Darwin")
        go_init
        build_unix
        ;;
    *)
        exit 1
        ;;
esac
