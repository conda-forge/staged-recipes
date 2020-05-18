# Use Gold linker and -Wl,--as-needed as suggested in
# https://github.com/conda-forge/staged-recipes/pull/11589#issuecomment-629882668
export LDFLAGS="${LDFLAGS:-} -fuse-ld=gold -Wl,--as-needed"

./configure \
  --prefix=${PREFIX} \
  --with-gtk="3" \
  --with-opengl

[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j ${CPU_COUNT}
make install
