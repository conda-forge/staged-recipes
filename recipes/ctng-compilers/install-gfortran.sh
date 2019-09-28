set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)
_libdir=libexec/gcc/${CHOST}/${PKG_VERSION}

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${CHOST}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/.build/${CHOST}/build/build-cc-gcc-final/

# adapted from Arch install script from https://github.com/archlinuxarm/PKGBUILDs/blob/master/core/gcc/PKGBUILD
# We cannot make install since .la files are not relocatable so libtool deliberately prevents it:
# libtool: install: error: cannot install `libgfortran.la' to a directory not ending in ${SRC_DIR}/work/gcc_built/${CHOST}/lib/../lib
make -C ${CHOST}/libgfortran prefix=${PREFIX} all-multi libgfortran.spec ieee_arithmetic.mod ieee_exceptions.mod ieee_features.mod config.h
make -C gcc prefix=${PREFIX} fortran.install-{common,man,info}

# How it used to be:
# install -Dm755 gcc/f951 ${PREFIX}/${_libdir}/f951
for file in f951; do
  if [[ -f gcc/${file} ]]; then
    install -c gcc/${file} ${PREFIX}/${_libdir}/${file}
  fi
done

mkdir -p ${PREFIX}/${CHOST}/sysroot/lib
cp ${CHOST}/libgfortran/libgfortran.spec ${PREFIX}/${CHOST}/sysroot/lib

pushd ${PREFIX}/bin
  ln -s ${CHOST}-gfortran ${CHOST}-f95
popd

popd

mkdir -p $PREFIX/lib/gcc/${CHOST}/${ctng_gcc}/finclude
rsync -av ${SRC_DIR}/gcc_built/lib/gcc/${CHOST}/${ctng_gcc}/finclude/ $PREFIX/lib/gcc/${CHOST}/${ctng_gcc}/finclude

# Install Runtime Library Exception
install -Dm644 $SRC_DIR/.build/src/gcc-${PKG_VERSION}/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/gcc-fortran/RUNTIME.LIBRARY.EXCEPTION

# generate specfile so that we can patch loader link path
# link_libgcc should have the gcc's own libraries by default (-R)
# so that LD_LIBRARY_PATH isn't required for basic libraries.
#
# GF method here to create specs file and edit it.  The other methods
# tried had no effect on the result.  including:
#   setting LINK_LIBGCC_SPECS on configure
#   setting LINK_LIBGCC_SPECS on make
#   setting LINK_LIBGCC_SPECS in gcc/Makefile
specdir=`dirname $($PREFIX/bin/${CHOST}-gcc -print-libgcc-file-name -no-canonical-prefixes)`
mv $PREFIX/bin/${CHOST}-gfortran $PREFIX/bin/${CHOST}-gfortran.bin
echo '#!/bin/sh' > $PREFIX/bin/${CHOST}-gfortran
echo $PREFIX/bin/${CHOST}-gfortran.bin -specs=$specdir/specs '"$@"' >> $PREFIX/bin/${CHOST}-gfortran
chmod +x $PREFIX/bin/${CHOST}-gfortran

# Strip executables, we may want to install to a different prefix
# and strip in there so that we do not change files that are not
# part of this package.
pushd ${PREFIX}
  _files=$(find . -type f)
  for _file in ${_files}; do
    _type="$( file "${_file}" | cut -d ' ' -f 2- )"
    case "${_type}" in
      *script*executable*)
      ;;
      *executable*)
        ${SRC_DIR}/gcc_built/bin/${CHOST}-strip --strip-all -v "${_file}"
      ;;
    esac
  done
popd
