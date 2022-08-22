set -x

autoreconf -ivf

mkdir _builddir

pushd _builddir

../configure --disable-dependency-tracking
make
make install

popd
