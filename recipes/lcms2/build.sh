./configure                     \
            --prefix=$PREFIX    \
            --with-jpeg=$PREFIX \
            --with-tiff=$PREFIX \
            --with-zlib=$PREFIX

make

# There is a bug in the build system for the tests on OS X.
# This should work on Linux though.
if [[ `uname` != "Darwin" ]]
then
    make check
fi

make install
