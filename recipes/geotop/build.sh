mkdir build
meson build
cd build
meson configure -DMUTE_GEOLOG=true -DMUTE_GEOTIMER=true -Db_lto=true
ninja geotop
mkdir -p $PREFIX/bin
install geotop $PREFIX/bin/geotop

