set -x

autoreconf -ivf

mkdir _builddir

pushd _builddir

../configure --disable-dependency-tracking --prefix=$PREFIX
make
make install

popd
