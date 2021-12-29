# The Makefile checks for the ARCH variable
# and expects it to be one of a few known values
# x86_64 is expected to be specified as 64
if [[ ${ARCH} == "64" ]]; then
    export ARCH=x86_64
fi

# Remove the static library from being installed
sed -i 's/libhugetlbfs.a//g' Makefile

# We only bulid native, so we want this to go to the correct location
# The location is lib, nomatter what
# The Makefile concatenates this with the PREFIX environment variable
export LIB64=lib
export LIB32=lib

export BUILDTYPE=NATIVEONLY
# Make library and tools, but not tests
make libs tools -j${CPU_COUNT}

# Do not install man pages
make install-libs install-bin
