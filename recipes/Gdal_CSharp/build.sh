
#!/bin/bash

set -ex # Abort on error.

# Force python bindings to not be built.
unset PYTHON

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

# Filter out -std=.* from CXXFLAGS as it disrupts checks for C++ language levels.
re='(.*[[:space:]])\-std\=[^[:space:]]*(.*)'
if [[ "${CXXFLAGS}" =~ $re ]]; then
    export CXXFLAGS="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
fi

# See https://github.com/AnacondaRecipes/aggregate/pull/103
if [[ $target_platform =~ linux.* ]]; then
  export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath-link,${PREFIX}/lib"
  mkdir -p ${PREFIX}/include/linux
  cp ${RECIPE_DIR}/userfaultfd.h ${PREFIX}/include/linux/userfaultfd.h
fi

cp ${RECIPE_DIR}/libgdal.la ../..
mkdir -p ../../.libs
cp ${PREFIX}/lib/libgdal.* ../../.libs

bash configure --prefix=${PREFIX} \
               --host=${HOST} \
               --with-curl \
               --with-dods-root=${PREFIX} \
               --with-expat=${PREFIX} \
               --with-freexl=${PREFIX} \
               --with-geos=${PREFIX}/bin/geos-config \
               --with-geotiff=${PREFIX} \
               --with-hdf4=${PREFIX} \
               --with-cfitsio=${PREFIX} \
               --with-hdf5=${PREFIX} \
               --with-tiledb=${PREFIX} \
               --with-jpeg=${PREFIX} \
               --with-kea=${PREFIX}/bin/kea-config \
               --with-kea=${PREFIX}/bin/kea-config \
               --with-libiconv-prefix=${PREFIX} \
               --with-libjson-c=${PREFIX} \
               --with-libkml=${PREFIX} \
               --with-liblzma=yes \
               --with-libtiff=${PREFIX} \
               --with-libz=${PREFIX} \
               --with-netcdf=${PREFIX} \
               --with-openjpeg=${PREFIX} \
               --with-pcre \
               --with-pg=yes \
               --with-png=${PREFIX} \
               --with-poppler=${PREFIX} \
               --with-spatialite=${PREFIX} \
               --with-sqlite3=${PREFIX} \
               --with-proj=${PREFIX} \
               --with-webp=${PREFIX} \
               --with-xerces=${PREFIX} \
               --with-xml2=yes \
               --with-zstd=${PREFIX} \
               --without-python \
               --disable-static \
               --verbose \
               ${OPTS}

cd swig/csharp

make ${VERBOSE_AT} interface

make ${VERBOSE_AT}

make install ${VERBOSE_AT}

if [[ $target_platform =~ linux.* ]]; then
  rm ${PREFIX}/include/linux/userfaultfd.h
fi

