#!/usr/bin/env bash

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
    pushd 'src/github.com/'

    # The change in the name of etcd-io messed up file paths.
    # Hence, copy etcd-io and compile zetcd using coreos

    cp -r etcd-io coreos

    # from the release-binary file
    REPO_PATH=github.com/coreos/zetcd

    go build -o $PREFIX/bin/zetcd -v \
      -ldflags "-w -X $REPO_PATH/version.Version=$VERSION -X $REPO_PATH/version.SHA=$SHA" \
      $REPO_PATH/cmd/zetcd

    go build -o $PREFIX/bin/zkctl ./etcd-io/zetcd/cmd/zkctl
    go build -o $PREFIX/bin/zkboom ./etcd-io/zetcd/cmd/zkboom

    #mv $GOPATH/bin/zetcd $PREFIX/bin/
    # remove coreos since its a copy o etcd-io
    rm -rf coreos
}

case $(uname -s) in
    "Linux"|"Darwin")
        git_init
        build_unix
        ;;
    *)
        exit 1
        ;;
esac
