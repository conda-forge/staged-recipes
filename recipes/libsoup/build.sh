set -ex

# necessary to ensure the gobject-introspection-1.0 pkg-config file gets found
# meson needs this to determine where the g-ir-scanner script is located
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig

# set the path to the modules explicitly, as they won't get found otherwise
export GIO_MODULE_DIR=$PREFIX/lib/gio/modules

# _BSD_SOURCE must be set on old versions of Linux to expose some typedefs
export CPPFLAGS="-D_BSD_SOURCE=1 ${CPPFLAGS}"

meson setup builddir \
	--prefix=$PREFIX \
	--libdir=lib \
	-Dbrotli=enabled \
	-Dintrospection=enabled \
	-Dtests=false \
	-Dvapi=disabled \
	-Dgssapi=disabled \
	-Dkrb5_config=disabled
ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}
