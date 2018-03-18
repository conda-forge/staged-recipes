#!/usr/bin/env bash

make_goroot_read_only()
{
    find $PREFIX/go -type d -exec chmod 555 {} \;
}

build_linux()
{
    find -type f -exec sed -i'' "s|/etc/cni/net\.d|$PREFIX/etc/cni/net\.d|g" {} \;
    ./build.sh

    cp bin/cnitool $PREFIX/lib
    mkdir -p $PREFIX/lib/cni && touch $PREFIX/lib/cni/.mkdir
    mkdir -p $PREFIX/etc/cni/net.d && touch $PREFIX/etc/cni/net.d/.mkdir

    for i in activate deactivate; do
        dest_dir=$PREFIX/etc/conda/$i.d
        mkdir -p $dest_dir
        cp $RECIPE_DIR/$i.sh $dest_dir/cni.sh
    done
}

make_goroot_read_only

case $(uname -s) in
    "Linux")
        build_linux
        ;;
esac
