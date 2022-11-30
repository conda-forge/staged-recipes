set -x

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./

# We need to explicitly set the python path
export ac_cv_path_PYTHON=$PREFIX/bin/python

./configure --prefix=$PREFIX --with-netcdf4=$PREFIX

make
make check
make install
