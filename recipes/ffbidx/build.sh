CUDA_HOME=${BUILD_PREFIX} meson setup --reconfigure --buildtype=release --prefix=${PREFIX} --libdir=lib -Ddefault_library=shared -Dinclude-python-api=enabled meson $MESON_ARGS
cd meson
meson compile
meson install
mkdir -p ${SP_DIR}
mv ${PREFIX}/lib/ffbidx ${SP_DIR}
rm -rf ${PREFIX}/share/ffbidx
rm -rf ${PREFIX}/include
