#!/bin/bash

if [ $(uname) == Darwin ]; then
    PGFLAG=""
    export LDFLAGS="-headerpad_max_install_names"
else
    PGFLAG="--with-pg=$PREFIX/bin/pg_config"
fi

# Ensure it does not find python.
export PYTHON=

CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" \
./configure --prefix=$PREFIX \
            --with-hdf4=$PREFIX \
            --with-hdf5=$PREFIX \
            --with-xerces=$PREFIX \
            --with-netcdf=$PREFIX \
            --with-geos=$PREFIX/bin/geos-config \
            --with-kea=$PREFIX/bin/kea-config \
            --with-static-proj4=$PREFIX \
            --with-openjpeg=$PREFIX \
            --with-python=no \
            --disable-rpath \
            --without-pam \
            $PGFLAG

make
make install

# Copy data files.
mkdir -p $PREFIX/share/gdal/
cp data/*csv $PREFIX/share/gdal/
cp data/*wkt $PREFIX/share/gdal/

if [ $(uname) == Darwin ]; then
    # Copy TIFF and GEOTIFF Headers so can build against gdal internal geotiff/tiff libraries.
    mkdir -p $PREFIX/include/gdal/frmts/gtiff/libgeotiff
    cp frmts/gtiff/libgeotiff/*.h $PREFIX/include/gdal/frmts/gtiff/libgeotiff
    cp frmts/gtiff/libgeotiff/*.inc $PREFIX/include/gdal/frmts/gtiff/libgeotiff
    mkdir -p $PREFIX/include/gdal/frmts/gtiff/libtiff
    cp frmts/gtiff/libtiff/*.h $PREFIX/include/gdal/frmts/gtiff/libtiff
fi

# Make sure GDAL_DATA and set and still present in the package
# https://github.com/conda/conda-recipes/pull/267
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/gdal-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/gdal-deactivate.sh
