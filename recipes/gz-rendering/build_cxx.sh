#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Workaround for PRIu64 not being defined
# See https://github.com/conda-forge/staged-recipes/pull/18792#issuecomment-1114606992
export CXXFLAGS="-D__STDC_FORMAT_MACROS $CXXFLAGS"

mkdir -p build
cd build

export CFLAGS="${CFLAGS} -DGLX_GLXEXT_LEGACY"
export CXXFLAGS="${CXXFLAGS} -DGLX_GLXEXT_LEGACY"

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DFREEIMAGE_RUNS:BOOL=ON \
      -DFREEIMAGE_RUNS__TRYRUN_OUTPUT:STRING="" \
      -DFREEIMAGE_COMPILES:BOOL=ON \
      -DSKIP_optix:BOOL=ON

cmake --build . --config Release
cmake --build . --config Release --target install

# UNIT_Heightmap_TEST disabled for https://github.com/conda-forge/libignition-rendering4-feedstock/issues/10
# if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
# Do not run tests as they require to open a display and this is not supported on CI at the moment
# See https://github.com/conda-forge/libignition-rendering4-feedstock/pull/19#issuecomment-937678806
# ctest --extra-verbose --output-on-failure -C Release -E "INTEGRATION|PERFORMANCE|REGRESSION|UNIT_RenderingIface_TEST|check_UNIT_RenderingIface_TEST|UNIT_Heightmap_TEST"
# fi

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
