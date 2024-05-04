#!/usr/bin/env bash

set -ex -o pipefail

# Remove static libraries from the prefix to prevent static linking
rm $PREFIX/lib/*.a

mkdir oag
mkdir epics

# Archives have overlapping directories. Additionally, conda will remove empty
# top-level directories which is not what we want.  So here we combine
# all of the extracted contents into their correct spots:
cp -r src/elegant/* oag
cp -r src/oag-apps/* oag
cp -r src/sdds/* epics/
cp -r src/epics-base/* epics/
cp -r src/epics-extensions/* epics/

rm -rf src/

if ! command -v mpicc; then
  echo "* mpicc not found? Was the environment built correctly?"
  exit 1
fi

echo "* Work root:    $SRC_DIR"
echo "* Conda prefix: $PREFIX"

echo "* Removing vendored libraries"
rm -rfv "${SRC_DIR}/epics/extensions/src/SDDS/png"
rm -rfv "${SRC_DIR}/epics/extensions/src/SDDS/gd"
rm -rfv "${SRC_DIR}/epics/extensions/src/SDDS/lzma"
rm -rfv "${SRC_DIR}/epics/extensions/src/SDDS/tiff"
rm -rfv "${SRC_DIR}/epics/extensions/src/SDDS/zlib"

echo "* Patching Makefiles to not use vendored libraries"
# The build system will try to use these regardless of our settings:
sed -i -e '/^DIRS += zlib lzma$/d' "${SRC_DIR}/epics/extensions/src/SDDS/Makefile"
sed -i -e '/^DIRS += png$/d' "${SRC_DIR}/epics/extensions/src/SDDS/Makefile"
sed -i -e '/^DIRS += gd$/d' "${SRC_DIR}/epics/extensions/src/SDDS/Makefile"
sed -i -e '/^DIRS += tiff$/d' "${SRC_DIR}/epics/extensions/src/SDDS/Makefile"
# This will also force it to use the vendored zlib:
sed -i -e '/^mdblib_DEPEND_DIRS = zlib$/d' "${SRC_DIR}/epics/extensions/src/SDDS/Makefile"

echo "* Patching EPICS_BASE path for oag"
# shellcheck disable=SC2016
sed -i -e 's@^#\s*EPICS_BASE.*@EPICS_BASE=$(TOP)/../../epics/base@' "${SRC_DIR}/oag/apps/configure/RELEASE"

EPICS_HOST_ARCH=$("${SRC_DIR}"/epics/base/startup/EpicsHostArch)
echo "* EPICS_HOST_ARCH=${EPICS_HOST_ARCH}"

MAKE_ALL_ARGS=(
  "HDF_LIB_LOCATION=$PREFIX/lib"
  "EPICS_HOST_ARCH=$EPICS_HOST_ARCH"
  "SVN_VERSION=$PKG_VERSION"
  "zlib_DIR=$PREFIX/lib"
  "lzma_DIR=$PREFIX/lib"
  "png_DIR=$PREFIX/lib"
  "gd_DIR=$PREFIX/lib"
  "tiff_DIR=$PREFIX/lib"
)
MAKE_GSL_ARGS=(
  "GSL=1"
  "gsl_DIR=$PREFIX/lib"
  "gslcblas_DIR=$PREFIX/lib"
)
MAKE_MPI_ARGS=(
  "MPI=1"
  "MPI_PATH=$(dirname "$(which mpicc)")/"
  "MPICH_CC=$CC"
  "MPICH_CXX=$CXX"
)

PYTHON_VERSION="$PY_VER"

echo "* Make args:          ${MAKE_ALL_ARGS[*]}"
echo "* Make GSL args:      ${MAKE_GSL_ARGS[*]}"
echo "* Make MPI args:      ${MAKE_MPI_ARGS[*]}"
echo "* Python version:     $PYTHON_VERSION"

echo "* Setting compilers for epics-base"

cat <<EOF >> "${SRC_DIR}/epics/base/configure/os/CONFIG_SITE.Common.${EPICS_HOST_ARCH}"
CC=$CC
CCC=$CXX

COMMANDLINE_LIBRARY=
LINKER_USE_RPATH=NO

USR_INCLUDES+= -I $PREFIX/include
USR_LDFLAGS=$LDFLAGS
HDF_LIB_LOCATION=$PREFIX/lib
USER_MPI_FLAGS="-DUSE_MPI=1 -DSDDS_MPI_IO=1 -I${PREFIX}/include"
EOF

if [[ $(uname -s) == 'Linux' ]]; then
  cat <<EOF >> "${SRC_DIR}/epics/base/configure/os/CONFIG_SITE.Common.${EPICS_HOST_ARCH}"
USR_LDFLAGS+= -Wl,--disable-new-dtags -Wl,-rpath-link,${PREFIX}/lib
EOF
  # On Linux, ensure libgomp is included during linking:
  sed -i -e "s/PROD_SYS_LIBS\s*+=.*/\0 gomp/" \
    "$SRC_DIR/epics/extensions/src/SDDS/SDDSaps/Makefile" \
    "$SRC_DIR/epics/extensions/src/SDDS/SDDSaps/sddscontours/Makefile" \
    "$SRC_DIR/epics/extensions/src/SDDS/SDDSaps/pseudoInverse/Makefile"
  sed -i -e "s/PROD_SYS_LIBS_DEFAULT\s*=.*/\0 gomp/" \
    "$SRC_DIR/epics/extensions/src/SDDS/SDDSaps/sddsplots/Makefile"
elif [[ $(uname -s) == 'Darwin' ]]; then
  # Skipping pseudoInverse and sddscontours for now on Darwin.
  # Outside of conda-forge infrastructure with a modern MacOS SDK, these build
  # without issue. The older MacOS SDK that conda-forge uses has issues with
  # pseudoInverse and lapack/blas.
  MAKE_ALL_ARGS+=( "BUILD_PSEUDOINVERSE=0" )
  sed -i -e "s#^DIRS += SDDSaps/sddscontours##" \
    "$SRC_DIR/epics/extensions/src/SDDS/Makefile"
  sed -i -e "s/^DIRS =.*/DIRS = sddsplots/" \
    "$SRC_DIR/epics/extensions/src/SDDS/SDDSaps/Makefile"
  # oag overwrites USR_CFLAGS; append to the arch-specific ones here instead
  # to avoid warnings which have become fatal errors:
  cat <<EOF >> "${SRC_DIR}/epics/base/configure/os/CONFIG_SITE.Common.${EPICS_HOST_ARCH}"
USR_CFLAGS_Darwin += -Wno-error=incompatible-function-pointer-types
USR_CXXFLAGS_Darwin += -Wno-error=register
EOF
fi

# APS may have this patched locally; these were changed long before 1.12.1
# which they reportedly use:
SDDS_UTILS="${SRC_DIR}/epics/extensions/src/SDDS/utils"
sed -i -e 's/H5Dopen(/H5Dopen1(/g' "$SDDS_UTILS/"*.c
sed -i -e 's/H5Aiterate(/H5Aiterate1(/g'  "$SDDS_UTILS/"*.c
sed -i -e 's/H5Acreate(/H5Acreate1(/g' "$SDDS_UTILS/"*.c
sed -i -e 's/H5Gcreate(/H5Gcreate1(/g' "$SDDS_UTILS/"*.c
sed -i -e 's/H5Dcreate(/H5Dcreate1(/g' "$SDDS_UTILS/"*.c

sed -i -e 's/^epicsShareFuncFDLIBM //g' "${SRC_DIR}/epics/extensions/src/SDDS/include"/*.h

# Sorry, we're not going to build the motif driver.
echo -e "all:\ninstall:\nclean:\n" > "${SRC_DIR}/epics/extensions/src/SDDS/SDDSaps/sddsplots/motifDriver/Makefile"

echo "* Setting up EPICS build system"
make -C "${SRC_DIR}/epics/base"

echo "* Patching SDDS utils"
echo "* Building SDDS"
# First, build some non-MPI things (otherwise we don't get editstring, nlpp)
make -C "${SRC_DIR}/epics/extensions/src/SDDS" "${MAKE_ALL_ARGS[@]}"

# Clean out the artifacts from the non-MPI build and then build with MPI:
echo "* Cleaning non-MPI build"
make -C "${SRC_DIR}/epics/extensions/src/SDDS" clean

echo "* Building SDDSlib with MPI"
make -C "${SRC_DIR}/epics/extensions/src/SDDS/SDDSlib" "${MAKE_MPI_ARGS[@]}" "${MAKE_ALL_ARGS[@]}"

echo "* Building SDDS tools"
make -C "${SRC_DIR}/oag/apps/src/utils/tools" "${MAKE_ALL_ARGS[@]}" "${MAKE_MPI_ARGS[@]}"

# We may not *need* to build these individually. However these are the bare
# minimum necessary for Pelegant. So let's go with it for now.
for sdds_part in \
  pgapack    \
  cmatlib    \
; do
  echo "* Building SDDS $sdds_part"
  make -C "${SRC_DIR}/epics/extensions/src/SDDS/${sdds_part}" "${MAKE_MPI_ARGS[@]}"
done

echo "* Building SDDS python"
make -C "${SRC_DIR}/epics/extensions/src/SDDS/python" \
  "${MAKE_ALL_ARGS[@]}" \
  "${MAKE_MPI_ARGS[@]}" \
  PYTHON3=1 \
  PYTHON_PREFIX="$PREFIX" \
  PYTHON_EXEC_PREFIX="$PREFIX" \
  PYTHON_VERSION="$PY_VER" \
  LIB_LIBS="SDDS1 rpnlib mdblib mdbmth" \
  USR_SYS_LIBS="python${PYTHON_VERSION} lzma"

echo "* Adding extension bin directory to PATH for nlpp"
export PATH="${SRC_DIR}/epics/extensions/bin/${EPICS_HOST_ARCH}:$PATH"

ELEGANT_ROOT="${SRC_DIR}/oag/apps/src/elegant"

if [[ $(uname -s) == 'Linux' ]]; then
  # Include libgomp for Linux builds for the remainder of the tools
  cat <<EOF >> "${SRC_DIR}/epics/base/configure/os/CONFIG_SITE.Common.${EPICS_HOST_ARCH}"
USR_LDFLAGS+= -lgomp
EOF
fi

echo "* Building parallel elegant first"
make -C "${ELEGANT_ROOT}" \
  Pelegant \
  "${MAKE_ALL_ARGS[@]}" \
  "${MAKE_MPI_ARGS[@]}" \
  "${MAKE_GSL_ARGS[@]}"

echo "* Building regular elegant second"
make -C "${ELEGANT_ROOT}" \
  MPI=0 NOMPI=1 \
  "${MAKE_ALL_ARGS[@]}" \
  "${MAKE_GSL_ARGS[@]}"

for build_path in \
  "${SRC_DIR}/oag/apps/src/physics" \
  "${SRC_DIR}/oag/apps/src/xraylib" \
  "${ELEGANT_ROOT}/elegantTools" \
; do
  echo "* Building $build_path"
  make -C "$build_path" "${MAKE_ALL_ARGS[@]}" "${MAKE_GSL_ARGS[@]}"
done

echo "* Building sddsbrightness (Fortran)"
make -C "${ELEGANT_ROOT}/sddsbrightness" \
  "${MAKE_ALL_ARGS[@]}" \
  "${MAKE_GSL_ARGS[@]}" \
  F77="${GFORTRAN} -m64 -ffixed-line-length-132" \
  static_flags="-L$PREFIX/lib"

echo "* Build succeeded"

echo "* Making binaries writeable so patchelf/install_name_tool will work"
chmod +w "${SRC_DIR}/oag/apps/bin/${EPICS_HOST_ARCH}/"*
chmod +w "${SRC_DIR}/epics/extensions/bin/${EPICS_HOST_ARCH}/"*
chmod +w "${SRC_DIR}/epics/extensions/lib/${EPICS_HOST_ARCH}/"*

SITE_PACKAGES_DIR="$PREFIX/lib/python${PY_VER}/site-packages"

echo "* Installing sdds library to $SITE_PACKAGES_DIR"
cp "${SRC_DIR}/epics/extensions/src/SDDS/python/sdds.py" "$SITE_PACKAGES_DIR"
cp "${SRC_DIR}/epics/extensions/lib/${EPICS_HOST_ARCH}/sddsdata."* "$SITE_PACKAGES_DIR/sddsdata.so"

echo "* Installing binaries to $PREFIX"
cp "${SRC_DIR}/oag/apps/bin/${EPICS_HOST_ARCH}/"* "${PREFIX}/bin"
cp "${SRC_DIR}/epics/extensions/bin/${EPICS_HOST_ARCH}/"* "${PREFIX}/bin"
