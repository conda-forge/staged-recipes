#!/bin/sh

mkdir build
cd build

cmake -B build -S . \
	   -GNinja  \
     -DCMAKE_INSTALL_PREFIX=$PREFIX \
	   -DCMAKE_BUILD_TYPE=Release \
       ${CMAKE_ARGS}

cmake --build build --config Release -j${CPU_COUNT}

if [[ ("${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "") ]]; then
  ctest --test-dir build --output-on-failure --repeat until-pass:5 -C Release 
fi

cmake --build build --config Release --target install

# Generate and copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    multisheller ${RECIPE_DIR}/${CHANGE}.msh --output ./${CHANGE}
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    cp "${CHANGE}.bash" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.bash"
    cp "${CHANGE}.xsh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.xsh"
    cp "${CHANGE}.zsh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.zsh"
    cp "${CHANGE}.ps1" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.ps1"
done
