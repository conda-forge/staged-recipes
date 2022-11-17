set -eu

mkdir -p use
mkdir -p m4
autoheader
aclocal
libtoolize --automake --copy
automake --add-missing --copy
autoconf
autoreconf

./configure --prefix=$PREFIX

make
make install
