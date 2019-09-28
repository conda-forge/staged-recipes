set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${CHOST}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

mkdir -p ${PREFIX}/lib/
rm -f ${PREFIX}/lib/libgfortran* || true

cp -f --no-dereference ${SRC_DIR}/gcc_built/${CHOST}/sysroot/lib/libgfortran*.so* ${PREFIX}/lib/

mkdir -p ${PREFIX}/${CHOST}/sysroot/lib || true
symtargets=$(find ${PREFIX}/lib -name "libgfortran*.so*")
for symtarget in ${symtargets}; do
  symtargetname=$(basename ${symtarget})
  ln -s ${PREFIX}/lib/${symtargetname} ${PREFIX}/${CHOST}/sysroot/lib/${symtargetname}
done

# Install Runtime Library Exception
install -Dm644 $SRC_DIR/.build/src/gcc-${PKG_VERSION}/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/libgfortran/RUNTIME.LIBRARY.EXCEPTION
