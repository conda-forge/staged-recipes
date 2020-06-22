#! /bin/bash
# Prior to conda-forge, Copyright 2014-2019 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -ex

meson_config_args=(
    -D gtk_doc=false
    -D vapi=false
    -D gir=true
    -D glade_catalog=false

)

# ensure that the post install script is ignored
export DESTDIR="/"

meson setup builddir \
    "${meson_config_args[@]}" \
    --prefix=$PREFIX \
    --libdir=$PREFIX/lib  \
    --wrap-mode=nofallback
ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}

# cd $PREFIX
# find . '(' -name '*.la' -o -name '*.a' ')' -delete
# rm -rf $(echo "
# share/applications
# share/gtk-doc
# share/man
# bin/gtk3-demo*
# bin/gtk3-icon-browser
# bin/gtk3-widget-factory
# ")