#! /bin/bash

# The invocation of this script is preceded by a `source activate` of the
# Conda environment. In conda ~ 4.2 (at least 4.2.13, probably other
# versions), the activate script can reset the important $IFS variable if
# there are any files in $PREFIX/etc/conda/activate.d. The `toolchain` package
# installs just such a file, and therefore this script ends up with a
# clobbered $IFS. So:
IFS=$' \t\n'

set -e

# Sigh, the easiest option is to just compile it all ourselves.
#
# The preset $CFLAGS are all ones that can/should be passed to gfortran.

FC=gfortran
FFLAGS="-g -O -fno-automatic -Wall -fPIC $CFLAGS"
CFLAGS="-g -O -Wall -fPIC $CFLAGS"

mkdir -p $PREFIX/bin $PREFIX/lib $PREFIX/include

if [ -n "$OSX_ARCH" ] ; then
    SOEXT=dylib # see other choice; there's a reason we're not using $SHLIB_EXT
    SOFLAGS=(
	-dynamiclib
	-static-libgfortran
	-install_name '@rpath/librpfits.dylib'
	-compatibility_version 1.0.0
	-current_version 1.0.0
	-headerpad_max_install_names
    )
    EXEFLAGS=(
	-dynamic
    )
else
    SOEXT=so.0 # note: the ".0" makes this not the same as $SHLIB_EXT
    SOFLAGS=(
	-shared
	-fPIC
	-Wl,-soname,librpfits.so.0
    )
    EXEFLAGS=()
fi

$FC "${SOFLAGS[@]}" $FFLAGS \
    -o $PREFIX/lib/librpfits.$SOEXT \
    code/*.f code/utdate.c code/darwin/*.f

for bin in rpfex rpfhdr ; do
    gcc "${EXEFLAGS[@]}" \
	-o $PREFIX/bin/$bin \
	code/$bin.c $PREFIX/lib/librpfits.$SOEXT
done

cp -a code/RPFITS.h code/rpfits.inc $PREFIX/include

if [ -z "$OSX_ARCH" ] ; then
    (cd $PREFIX/lib && ln -s librpfits.$SOEXT librpfits.so)
fi
