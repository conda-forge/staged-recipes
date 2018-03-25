#!/usr/bin/env bash

make_goroot_read_only()
{
    find $GOROOT -type d -exec chmod 555 {} \;
}

make_gopath()
{
 export GOPATH=$(pwd)/go
 export PATH=$GOPATH/bin:$PATH

 export GOSRC_DIR=$GOPATH/src/k8s.io/helm
 mkdir -p $GOSRC_DIR

 find . -maxdepth 1 -not -name '.' -and -not -name 'go' -exec mv {} $GOSRC_DIR/ \;
 cd $GOSRC_DIR
}

build_unix()
{
    make bootstrap
    make build


}

make_goroot_read_only
make_gopath

case $(uname -s) in
    "Linux"|"Darwin")
        build_unix
        ;;
esac
