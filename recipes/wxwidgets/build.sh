./configure --prefix=${PREFIX} --with-gtk="3"
[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j ${CPU_COUNT}
make install
