cuda_home=$(which nvcc)
cuda_home=${cuda_home%/bin/nvcc}
CUDA_HOME=${cuda_home} meson setup $MESON_ARGS --reconfigure -Ddefault_library=shared -Dinclude-python-api=enabled -Dpython-installation=${PREFIX}/bin/python3 meson
cd meson
meson compile
meson install
mkdir -p ${SP_DIR}
mv ${PREFIX}/lib/ffbidx ${SP_DIR}
rm -rf ${PREFIX}/share/ffbidx
rm -rf ${PREFIX}/include
