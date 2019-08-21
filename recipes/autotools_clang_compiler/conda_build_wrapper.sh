export PATH="$PREFIX/bin:$BUILD_PREFIX/Library/bin:$SRC_DIR:$PATH"
export CC=cl_wrapper.sh
export CXX=cl_wrapper.sh
export RANLIB=llvm-ranlib
export AS=llvm-as
export AR=llvm-ar
export NM=llvm-nm
export LD=lld-link
export CCCL=clang-cl
export CFLAGS="-MD -I$PREFIX/include -O2 -D_CRT_SECURE_NO_WARNINGS"
export CXXFLAGS="-MD -I$PREFIX/include -O2 -EHs -D_CRT_SECURE_NO_WARNINGS"
export LDFLAGS="-L$PREFIX/lib"
export lt_cv_deplibs_check_method=pass_all

echo "You need to run patch_libtool bash function after configure to fix the libtool script."
echo "If your package uses OpenMP, add llvm-openmp to your host and run requirements."

patch_libtool () {
    # libtool has support for exporting symbols using either nm or dumpbin with some creative use of sed and awk,
    # but neither works correctly with C++ mangling schemes.
    # cmake's dll creation tool works, but need to hack libtool to get it working
    sed -i.bak "s/export_symbols_cmds=/export_symbols_cmds2=/g" libtool
    sed "s/archive_expsym_cmds=/archive_expsym_cmds2=/g" libtool > libtool2
    echo "#!/bin/bash" > libtool
    echo "export_symbols_cmds=\"echo \\\$libobjs | \\\$SED 's/ /\n/g'  > \\\$export_symbols.tmp && cmake -E __create_def \\\$export_symbols \\\$export_symbols.tmp\"" >> libtool
    echo "archive_expsym_cmds=\"\\\$CC -o \\\$tool_output_objdir\\\$soname \\\$libobjs \\\$compiler_flags \\\$deplibs -Wl,-DEF:\\\\\\\"\\\$export_symbols\\\\\\\" -Wl,-DLL,-IMPLIB:\\\\\\\"\\\$tool_output_objdir\\\$libname.dll.lib\\\\\\\"; echo \"" >> libtool
    cat libtool2 >> libtool
}

# Rename libpng.lib to png.lib
LIB_RENAME_FILES=$(find ${PREFIX}/lib -maxdepth 1 -iname 'lib*.lib')
for file in $(LIB_RENAME_FILES); do
   libname=$(basename ${file})
   cp ${PREFIX}/lib/${libname} ${PREFIX}/lib/${libname:3}
done

bash -e ./build.sh

if [[ -f "${PREFIX}/lib/${PKG_NAME}.lib" ]]; then
    mv "${PREFIX}/lib/${PKG_NAME}.lib"     "${PREFIX}/lib/${PKG_NAME}_static.lib"
    mv "${PREFIX}/lib/${PKG_NAME}.dll.lib" "${PREFIX}/lib/${PKG_NAME}.lib"
fi

for file in $(LIB_RENAME_FILES); do
   libname=$(basename ${file})
   rm ${PREFIX}/lib/${libname:3}
done

