#! /bin/bash

set -ex

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig

export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share

meson_config_args=(
    -Dgtk_doc=false
    -Dman-pages=false
    -Dintrospection=enabled
    -Dbuild-examples=false
    -Dbuild-tests=false
    -Dwayland-backend=false
)

if test $(uname) == 'Darwin' ; then
	meson_config_args+=("-Dprint-cups=disabled")
	meson_config_args+=("-Dx11-backend=false")
	meson_config_args+=("-Dmacos-backend=true")
elif test $(uname) == 'Linux' ; then
	meson_config_args+=("-Dx11-backend=true")
	meson_config_args+=("-Dxinerama=enabled")
fi

# ensure that the post install script is ignored
export DESTDIR="/"

meson setup builddir \
    "${meson_config_args[@]}" \
    --default-library=shared \
    --buildtype=release \
    --prefix=$PREFIX \
    -Dlibdir=lib \
    --wrap-mode=nofallback \
    --force-fallback-for=sassc,libsass
ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}

# cleanup sassc files
rm $PREFIX/bin/sassc
rm $PREFIX/lib/libsass*
rm $PREFIX/lib/pkgconfig/libsass.pc
rm -r $PREFIX/include/sass
rm $PREFIX/include/sass*
