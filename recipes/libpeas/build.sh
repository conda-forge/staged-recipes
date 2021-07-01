set -ex

meson setup builddir \
	--prefix=$PREFIX \
	--libdir=lib \
      	-Dpython3=true \
      	-Dintrospection=true \
      	-Dvapi=false \
      	-Dwidgetry=true \
      	-Ddemos=false
ninja -v -C builddir -j 1
ninja -C builddir install -j 1
