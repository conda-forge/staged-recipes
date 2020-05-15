./configure \
  --prefix=${PREFIX} \
  --with-gtk="3" \
  --with-opengl

[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j ${CPU_COUNT}
make install
