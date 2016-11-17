#!/bin/sh

export CC=${PREFIX}/bin/gcc
export CXXFLAGS="-fPIC $CXXFLAGS"
export LDFLAGS="-L${PREFIX}/lib $LDFLAGS"
export CPPFLAGS="-I${PREFIX}/include $CPPFLAGS"
export CFLAGS="-I${PREFIX}/include $CFLAGS"

if [ "$(uname)" = "Darwin" ]; then
    if [ -d "/opt/X11" ]; then
        x11_lib="-L/opt/X11/lib"
        x11_inc="-I/opt/X11/include -I/opt/X11/include/freetype2"
    else
        echo "No X11 libs found. Exiting..." 1>&2
        exit
    fi

    conf_file=config/Darwin_Intel
elif [ "$(uname)" = "Linux" ]; then
    conf_file=config/LINUX
fi

mkdir triangle_tmp && cd triangle_tmp && curl -q http://www.netlib.org/voronoi/triangle.shar | sh && mv triangle.? ../ni/src/lib/hlu/. && cd -

# add "-std=c99" to compile config files -- not needed after NCL 6.3.0
sed -e "s/^\(#define CcOptions.*\)$/\1 -std=c99/" -i.backup "${conf_file}"

# fix path to cpp in ymake -- we should fix this in NCL
sed -e "s|^\(  set cpp = \)/lib/cpp$|\1${PREFIX}/bin/cpp|g" -i.backup config/ymake

# fix path to cpp in $conf_file
sed -e "s|/usr/bin/cpp|${PREFIX}/bin/cpp|g" -i.backup ${conf_file}

sed -e "s|\${PREFIX}|${PREFIX}|g" -e "s|\${x11_inc}|${x11_inc}|g" -e "s|\${x11_lib}|${x11_lib}|g" "${RECIPE_DIR}/Site.local.template" > config/Site.local

echo -e "n\n" | ./Configure
make Everything

ACTIVATE_DIR="$PREFIX/etc/conda/activate.d"
DEACTIVATE_DIR="$PREFIX/etc/conda/deactivate.d"

mkdir -p "$ACTIVATE_DIR"
mkdir -p "$DEACTIVATE_DIR"

cp "$RECIPE_DIR/scripts/activate.sh" "$ACTIVATE_DIR/ncl-activate.sh"
cp "$RECIPE_DIR/scripts/deactivate.sh" "$DEACTIVATE_DIR/ncl-deactivate.sh"
