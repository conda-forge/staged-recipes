#! /bin/bash

set -e

if [ -n "$OSX_ARCH" ] ; then
    export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    platform=macosx
    soext=dylib
else
    platform=linux
    soext=so
fi

# We've added stock (version 3) xerces-c as a build-time dep to make sure that
# we don't clobber any of its files -- if we create a file with the same name,
# conda-build will think that it comes from the main package. But, we don't
# actually want it to be available! So clobber its files.

rm -rf $PREFIX/include/xercesc $PREFIX/lib/libxerces-c* $PREFIX/lib/pkgconfig/xerces-c*

export XERCESCROOT=$(pwd)
cd src/xercesc
bash ./runConfigure -p$platform -cgcc -xg++ -minmem -nsocket -tnative -rpthread -b64 -P$PREFIX
make # note: build is not parallel-compatible
make install

# We need to rename our output files so as to not conflict with the files in
# the stock (version 3) xerces-c. This includes the unversion dynamic library
# files.

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
mv include/xercesc include/xercesc28
rm -f lib/libxerces-c.$soext lib/libxerces-depdom.$soext
