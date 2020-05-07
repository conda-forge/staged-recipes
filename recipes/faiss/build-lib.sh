CUDA_CONFIG_ARG=""
if [ ${cuda_compiler_version} != "None" ]; then
    CUDA_CONFIG_ARG="--with-cuda=${CUDA_HOME}"
fi

# Build vanilla version (no avx)
./configure --without-cuda \
  --prefix=${PREFIX} --exec-prefix=${PREFIX} \
  --with-blas=-lblas --with-lapack=-llapack \
  ${CUDA_CONFIG_ARG}

[[ "$target_platform" == "win-64" ]] && patch_libtool

# make sets SHAREDEXT correctly for linux/osx
make install

# make builds libfaiss.a & libfaiss.so; we only want the latter
rm ${PREFIX}/lib/libfaiss.a
