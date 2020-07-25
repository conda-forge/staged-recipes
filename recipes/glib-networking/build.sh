set -ex

export DESTDIR="/"

meson setup builddir \
	--prefix=$PREFIX \
	--libdir=lib \
	-Dopenssl=enabled \
	-Dgnutls=enabled
ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}
