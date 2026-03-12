#!/bin/sh

rm -rf build

cmake ${CMAKE_ARGS} -S . -B build -GNinja  \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON

cmake --build build --config Release

if [[ ("${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "") ]]; then
  ctest --output-on-failure --repeat until-pass:5 -C Release --test-dir build
fi

cmake --build build --config Release --target install

# Generate and copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
multisheller ${RECIPE_DIR}/activate.msh --output ./activate
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "activate.bash" "${PREFIX}/etc/conda/activate.d/ironcub-models_activate.sh"

multisheller ${RECIPE_DIR}/deactivate.msh --output ./deactivate
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "deactivate.bash" "${PREFIX}/etc/conda/deactivate.d/ironcub-models_deactivate.sh"
