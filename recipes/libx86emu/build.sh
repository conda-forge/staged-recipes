set -ex
VERSION=${PKG_VERSION}
MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -d. -f1)
MAKE_FLAGS="GIT2LOG=: VERSION=${VERSION} MAJOR_VERSION=${MAJOR_VERSION} LIBDIR=${PREFIX}/lib"

make clean
make CC=${CC} CFLAGS="${CFLAGS}" ${MAKE_FLAGS} shared

# Mostly taken from the makefile install section. We would have to rewrite it
# since it likes to install in /usr bye default, and I don't feel like patching
LIB_NAME=libx86emu.so.${VERSION}
LIB_SONAME=libx86emu.so.${MAJOR_VERSION}

mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

install -D ${LIB_NAME} ${PREFIX}/lib/${LIB_NAME}
ln -snf ${PREFIX}/lib/${LIB_NAME} ${PREFIX}/lib/${LIB_SONAME}
ln -snf ${PREFIX}/lib/${LIB_NAME} ${PREFIX}/lib/libx86emu.so
install -m 644 include/x86emu.h ${PREFIX}/include/x86emu.h
