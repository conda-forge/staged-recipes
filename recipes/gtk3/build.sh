#! /bin/bash
# Prior to conda-forge, Copyright 2014-2019 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -ex

meson_config_args=(
    -D gtk_doc=false
    -D demos=false
    -D examples=false
    -D installed_tests=false
    -D wayland_backend=false
)

if [ -n "$OSX_ARCH" ] ; then
    # Clashing libuuid causes compilation problems unless we do this. libuuid
    # is pulled in by xorg-libSM.
    rm -rf $PREFIX/include/uuid
else
    # Clashing libX11 and libXext causes overlinking problems unless we do this
    # libX11 is provided by xorg-libx11 and pulled in by cairo
    rm -rf $PREFIX/lib/libX11.so*
    rm -rf $PREFIX/lib/libXext.so*
fi

meson setup builddir "${meson_config_args[@]}" --prefix=$PREFIX --libdir=$PREFIX/lib
ninja -v -C builddir
ninja -C builddir install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf $(echo "
share/applications
share/gtk-doc
share/man
bin/gtk3-demo*
bin/gtk3-icon-browser
bin/gtk3-widget-factory
")
