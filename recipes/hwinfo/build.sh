set -ex
MAKE_FLAGS="HWINFO_VERSION=${PKG_VERSION} LIBDIR=${PREFIX}/lib"
# Parallel builds missing due to missing libhd.a dependency
make ${MAKE_FLAGS}


# make install, mostly taken from the Makefile
# but adapted for conda forge by
#   - not using sbin
#   - not installing things in /usr
#   - Using sed instead of perl for changing the version infromation
LIBHD_VERSION=$(cat VERSION)
LIBHD_MINOR_VERSION=$(cut -d . -f 2 VERSION)
LIBHD_MAJOR_VERSION=$(cut -d . -f 1 VERSION)

LIBHD_BASE=libhd
LIBHD_NAME=${LIBHD_BASE}.so.${LIBHD_VERSION}
LIBHD_SONAME=${LIBHD_BASE}.so.${LIBHD_MAJOR_VERSION}

LIBHD_SO=src/${LIBHD_NAME}

mkdir -p ${PREFIX}/lib/pkgconfig/
mkdir -p ${PREFIX}/include
mkdir -p ${PREFIX}/bin

install -m 755 hwinfo ${PREFIX}/bin
install -m 755 src/ids/convert_hd ${PREFIX}/bin

install ${LIBHD_SO} ${PREFIX}/lib
ln -snf ${LIBHD_NAME} ${PREFIX}/lib/${LIBHD_SONAME}
ln -snf ${LIBHD_SONAME} ${PREFIX}/lib/${LIBHD_BASE}.so

install -m 644 hwinfo.pc ${PREFIX}/lib/pkgconfig
install -m 644 src/hd/hd.h ${PREFIX}/include


# They hardcode the prefix to be /usr, lets overwrite it here
sed -i "s,^prefix=.*,prefix=${PREFIX}," "${PREFIX}/lib/pkgconfig/hwinfo.pc"
sed -i "s/^#define HD_VERSION\t.*/#define HD_VERSION ${LIBHD_MAJOR_VERSION}/" ${PREFIX}/include/hd.h
sed -i "s/^#define HD_MINOR_VERSION\t.*/#define HD_VERSION ${LIBHD_MINOR_VERSION}/" ${PREFIX}/include/hd.h

install -m 755 getsysinfo ${PREFIX}/bin
install -m 755 src/isdn/cdb/mk_isdnhwdb ${PREFIX}/bin

install -d -m 755 ${PREFIX}/share/hwinfo
install -m 644 src/isdn/cdb/ISDN.CDB.txt ${PREFIX}/share/hwinfo
install -m 644 src/isdn/cdb/ISDN.CDB.hwdb ${PREFIX}/share/hwinfo
