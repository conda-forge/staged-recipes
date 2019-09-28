set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)
_libdir=libexec/gcc/${CHOST}/${PKG_VERSION}

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${CHOST}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/.build/${CHOST}/build/build-cc-gcc-final/
  # We may not have built with plugin support so failure here is not fatal:
  make prefix=${PREFIX} install-lto-plugin || true
  make -C gcc prefix=${PREFIX} install-driver install-cpp install-gcc-ar install-headers install-plugin install-lto-wrapper install-collect2
  # not sure if this is the same as the line above.  Run both, just in case
  make -C lto-plugin prefix=${PREFIX} install
  install -dm755 ${PREFIX}/lib/bfd-plugins/

  # statically linked, so this so does not exist
  # ln -s $PREFIX/lib/gcc/$CHOST/liblto_plugin.so ${PREFIX}/lib/bfd-plugins/

  make -C libcpp prefix=${PREFIX} install

  # Include languages we do not have any other place for here (and also lto1)
  for file in gnat1 brig1 cc1 go1 lto1 cc1obj cc1objplus; do
    if [[ -f gcc/${file} ]]; then
      install -c gcc/${file} ${PREFIX}/${_libdir}/${file}
    fi
  done

  # https://github.com/gcc-mirror/gcc/blob/gcc-7_3_0-release/gcc/Makefile.in#L3481-L3526
  # Could have used install-common, but it also installs cxx binaries, which we
  # don't want in this package. We could patch it, or use the loop below:
  for file in gcov{,-tool,-dump}; do
    if [[ -f gcc/${file} ]]; then
      install -c gcc/${file} ${PREFIX}/bin/${CHOST}-${file}
    fi
  done

  make -C ${CHOST}/libgcc prefix=${PREFIX} install

  # mkdir -p $PREFIX/$CHOST/sysroot/lib

  # cp ${SRC_DIR}/gcc_built/$CHOST/sysroot/lib/libgomp.so* $PREFIX/$CHOST/sysroot/lib
  # if [ -e ${SRC_DIR}/gcc_built/$CHOST/sysroot/lib/libquadmath.so* ]; then
  #   cp ${SRC_DIR}/gcc_built/$CHOST/sysroot/lib/libquadmath.so* $PREFIX/$CHOST/sysroot/lib
  # fi

  make prefix=${PREFIX} install-libcc1
  install -d ${PREFIX}/share/gdb/auto-load/usr/lib

  make prefix=${PREFIX} install-fixincludes
  make -C gcc prefix=${PREFIX} install-mkheaders

  if [[ -d ${CHOST}/libgomp ]]; then
    make -C ${CHOST}/libgomp prefix=${PREFIX} install-nodist_{libsubinclude,toolexeclib}HEADERS
  fi

  if [[ -d ${CHOST}/libitm ]]; then
    make -C ${CHOST}/libitm prefix=${PREFIX} install-nodist_toolexeclibHEADERS
  fi

  if [[ -d ${CHOST}/libquadmath ]]; then
    make -C ${CHOST}/libquadmath prefix=${PREFIX} install-nodist_libsubincludeHEADERS
  fi

  if [[ -d ${CHOST}/libsanitizer ]]; then
    make -C ${CHOST}/libsanitizer prefix=${PREFIX} install-nodist_{saninclude,toolexeclib}HEADERS
  fi

  if [[ -d ${CHOST}/libsanitizer/asan ]]; then
    make -C ${CHOST}/libsanitizer/asan prefix=${PREFIX} install-nodist_toolexeclibHEADERS
  fi

  if [[ -d ${CHOST}/libsanitizer/tsan ]]; then
    make -C ${CHOST}/libsanitizer/tsan prefix=${PREFIX} install-nodist_toolexeclibHEADERS
  fi

  make -C libiberty prefix=${PREFIX} install
  # install PIC version of libiberty
  install -m644 libiberty/pic/libiberty.a ${PREFIX}/lib

  make -C gcc prefix=${PREFIX} install-man install-info

  make -C gcc prefix=${PREFIX} install-po

  # many packages expect this symlink
  [[ -f ${PREFIX}/bin/${CHOST}-cc ]] && rm ${PREFIX}/bin/${CHOST}-cc
  pushd ${PREFIX}/bin
    ln -s ${CHOST}-gcc ${CHOST}-cc
  popd

  # POSIX conformance launcher scripts for c89 and c99
  cat > ${PREFIX}/bin/c89 <<"EOF"
#!/bin/sh
fl="-std=c89"
for opt; do
  case "$opt" in
    -ansi|-std=c89|-std=iso9899:1990) fl="";;
    -std=*) echo "`basename $0` called with non ANSI/ISO C option $opt" >&2
      exit 1;;
  esac
done
exec gcc $fl ${1+"$@"}
EOF

  cat > ${PREFIX}/bin/c99 <<"EOF"
#!/bin/sh
fl="-std=c99"
for opt; do
  case "$opt" in
    -std=c99|-std=iso9899:1999) fl="";;
    -std=*) echo "`basename $0` called with non ISO C99 option $opt" >&2
      exit 1;;
  esac
done
exec gcc $fl ${1+"$@"}
EOF

  chmod 755 ${PREFIX}/bin/c{8,9}9

  rm ${PREFIX}/bin/${CHOST}-gcc-${PKG_VERSION}

popd

# Install kernel headers
kernel_arch=${ctng_cpu_arch}
if [[ ${kernel_arch} == aarch64 ]]; then
  kernel_arch=arm64
elif [[ ${kernel_arch} == i686 ]]; then
  kernel_arch=x86
fi

make -C ${SRC_DIR}/.build/src/linux-* CROSS_COMPILE=${CHOST}- O=${SRC_DIR}/.build/${CHOST}/build/build-kernel-headers ARCH=${kernel_arch} INSTALL_HDR_PATH=${PREFIX}/${CHOST}/sysroot/usr ${VERBOSE_AT} headers_install

if [[ ${ctng_libc} == gnu ]]; then
  # Install libc libraries
  pushd ${SRC_DIR}/.build/${CHOST}/build/build-libc-final/multilib
    make -l BUILD_CFLAGS="-O2 -g -I${SRC_DIR}/.build/${CHOST}/buildtools/include" \
            BUILD_LDFLAGS="-L${SRC_DIR}/.build/${CHOST}/buildtools/lib"           \
            install_root=${PREFIX}/${CHOST}/sysroot install
  popd
else
  # Install uClibc headers
  pushd ${SRC_DIR}/.build/${CHOST}/build/build-libc-startfiles/multilib
    make CROSS_COMPILE=${CHOST}- PREFIX=${PREFIX}/${CHOST}/sysroot MULTILIB_DIR=lib \
	     LOCALE_DATA_FILENAME=uClibc-locale-030818.tgz STRIPTOOL=true V=2 UCLIBC_EXTRA_CFLAGS=-pipe headers
  popd

  # Install uClibc libraries
  pushd ${SRC_DIR}/.build/${CHOST}/build/build-libc-final/multilib
    PATH=${SRC_DIR}/.build/${CHOST}/buildtools/${CHOST}/bin:$PATH \
      make CROSS_COMPILE=${CHOST}- PREFIX=${PREFIX}/${CHOST}/sysroot MULTILIB_DIR=lib                 \
	       LOCALE_DATA_FILENAME=uClibc-locale-030818.tgz STRIPTOOL=true V=2 UCLIBC_EXTRA_CFLAGS=-pipe \
		   install install_utils
  popd
fi

# generate specfile so that we can patch loader link path
# link_libgcc should have the gcc's own libraries by default (-R)
# so that LD_LIBRARY_PATH isn't required for basic libraries.
#
# GF method here to create specs file and edit it.  The other methods
# tried had no effect on the result.  including:
#   setting LINK_LIBGCC_SPECS on configure
#   setting LINK_LIBGCC_SPECS on make
#   setting LINK_LIBGCC_SPECS in gcc/Makefile
specdir=`dirname $($PREFIX/bin/${CHOST}-gcc -print-libgcc-file-name)`
$PREFIX/bin/${CHOST}-gcc -dumpspecs > $specdir/specs
# We use double quotes here because we want $PREFIX and $CHOST to be expanded at build time
#   and recorded in the specs file.  It will undergo a prefix replacement when our compiler
#   package is installed.
sed -i -e "/\*link_libgcc:/,+1 s+%.*+& -rpath ${PREFIX}/lib+" $specdir/specs

# Ensure that libgcc_s.so is found in the sysroot. I have done this to mask the fact that
# strong run_export packages do not get installed into the host prefix (AFAICT) and we
# should really fix that too. (ping @msarahan)
cp -f ${PREFIX}/${CHOST}/lib/libgcc_s.so* ${PREFIX}/${CHOST}/sysroot/lib

# Install Runtime Library Exception
install -Dm644 $SRC_DIR/.build/src/gcc-${PKG_VERSION}/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/gcc/RUNTIME.LIBRARY.EXCEPTION

# Next problem: macOS targetting uClibc ends up with broken symlinks in sysroot/usr/lib:
if [[ $(uname) == Darwin ]]; then
  pushd ${PREFIX}/${CHOST}/sysroot/usr/lib
  links=$(find . -type l | cut -c 3-)
  for link in ${links}; do
    target=$(readlink ${link} | sed 's#^/##' | sed 's#//#/#')
    rm ${link}
    ln -s ${target} ${link}
  done
  popd
fi

# Install the crosstool-ng config program to help with reproducibility:
cp ${SRC_DIR}/gcc_built/bin/${CHOST}-ct-ng.config ${PREFIX}/bin

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

${PREFIX}/bin/${CHOST}-gcc "${RECIPE_DIR}"/c11threads.c -std=c11
