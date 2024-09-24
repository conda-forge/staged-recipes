echo "Cuda version:"
echo "${cuda_compiler_version}"

if [[ "${cuda_compiler_version}" =~ "11" ]]; then
    echo 'cudaroot='${PREFIX}'
libdir=${cudaroot}/lib
includedir=${cudaroot}/include

Name: cudart
Description: CUDA Runtime Library
Version: '${cuda_compiler_version}'
Libs: -L${libdir} -lcudart
Cflags: -I${includedir}' > ${PREFIX}/lib/pkgconfig/cudart-${cuda_compiler_version}.pc
fi

echo "Environment:"
env
echo "Location of nvcc:"
which nvcc
echo "Package config:"
pkg-config --list-all
echo "Libs:"
ls ${PREFIX}/lib
echo "Include:"
ls ${PREFIX}/include

echo "Calling meson:"
cuda_home=$(which nvcc)
cuda_home=${cuda_home%/bin/nvcc}
CUDA_HOME=${cuda_home} meson setup $MESON_ARGS --reconfigure -Ddefault_library=shared -Dinclude-python-api=enabled meson
cd meson
meson compile
meson install
mkdir -p ${SP_DIR}
mv ${PREFIX}/lib/ffbidx ${SP_DIR}
rm -rf ${PREFIX}/share/ffbidx
rm -rf ${PREFIX}/include
