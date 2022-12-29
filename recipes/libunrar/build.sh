set -ex

if [[ ${target_platform} == linux-* ]]
then
  export CXXFLAGS="${CXXFLAGS} -O2 -Wno-logical-op-parentheses -Wno-switch -Wno-dangling-else"
  export LIBFLAGS="${LIBFLAGS} -fPIC"
  export DEFINES="${DEFINES} -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -DRAR_SMP"
else
  export CXXFLAGS="${CXXFLAGS} -O2"
  export DEFINES="${DEFINES} -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE"
fi

make lib
DESTDIR="${PREFIX}" make install-lib

make unrar
mkdir -p "${PREFIX}/bin"
DESTDIR="${PREFIX}" make install-unrar
ls -l "${PREFIX}/bin"

# Include header files
mkdir -p "${PREFIX}/include/unrar"
cp *.hpp "${PREFIX}/include/unrar"

# CFEP-18
rm "${PREFIX}/lib/libunrar.a"
