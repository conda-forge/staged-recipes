meson builddir -Ddocs=false --prefix=$PREFIX -Ddefault_library=shared
cd builddir
ninja
ninja install

set -x

# stuff gets installed into lib64 when we only use lib for conda
if [[ "$(uname -s)" =~ .*Linux.* ]]; then
    mkdir -p $PREFIX/lib
    if [[ -d $PREFIX/lib64 ]]; then
        mv -f $PREFIX/lib64/* $PREFIX/lib
        rm -rf $PREFIX/lib64
    fi
fi
