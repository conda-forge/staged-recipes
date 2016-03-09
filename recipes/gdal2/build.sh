#!/bin/bash

if [ `uname` == Darwin ]; then
    PGFLAG=""
    export LDFLAGS="-headerpad_max_install_names"
#    export CC=clang
#    export CXX=clang++
else
    PGFLAG="--with-pg=$PREFIX/bin/pg_config"
fi

CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" \
./configure --prefix=$PREFIX \
--with-geos=$PREFIX/bin/geos-config \
--with-static-proj4=$PREFIX \
--with-hdf5=$PREFIX \
--with-hdf4=$PREFIX \
--with-xerces=$PREFIX \
--with-armadillo=$PREFIX \
--with-netcdf=$PREFIX \
--with-openjpeg=$PREFIX \
--with-python \
--disable-rpath \
--without-pam \
$PGFLAG


make
make install

# Copy data files 
mkdir -p $PREFIX/share/gdal/
cp data/*csv $PREFIX/share/gdal/
cp data/*wkt $PREFIX/share/gdal/

if [ `uname` == Darwin ]; then
	# Copy TIFF and GEOTIFF Headers so can build against gdal internal geotiff/tiff libraries
	mkdir -p $PREFIX/include/gdal/frmts/gtiff/libgeotiff
	cp frmts/gtiff/libgeotiff/*.h $PREFIX/include/gdal/frmts/gtiff/libgeotiff
	cp frmts/gtiff/libgeotiff/*.inc $PREFIX/include/gdal/frmts/gtiff/libgeotiff
	mkdir -p $PREFIX/include/gdal/frmts/gtiff/libtiff
	cp frmts/gtiff/libtiff/*.h $PREFIX/include/gdal/frmts/gtiff/libtiff
fi
