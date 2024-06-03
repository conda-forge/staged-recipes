HOST=x86_64-w64-mingw32

if [[ "$target_platform" == "win-64" ]]; then
  INSTALL_PREFIX=${PREFIX}/Library/${HOST}/sysroot/usr
else
  INSTALL_PREFIX=${PREFIX}/${HOST}/sysroot/usr
fi

# Need to build gcc_bootstrap_win-64 in order to
# remove this hack, but let's build this package
# first to remove binary re-packaging
conda create -p $SRC_DIR/cf-compilers gcc_impl_win-64 --yes --quiet -c conda-forge/label/m2w64-experimental -c conda-forge

export PATH=$SRC_DIR/cf-compilers/bin:$PATH

./configure \
  --host=${HOST} \
  --prefix=${INSTALL_PREFIX} \

make -j${CPU_COUNT} install
