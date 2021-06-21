set -ex

# necessary to ensure the gobject-introspection-1.0 pkg-config file gets found
# meson needs this to determine where the g-ir-scanner script is located
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig

export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share

meson setup builddir \
	--prefix=$PREFIX \
	--libdir=lib \
	-Dwith_introspection=true \
	-Dwith_vapi=false
ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}
