#!/bin/bash

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

if [[ ${DEBUG_C} == yes ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi

# cmake_minimum_required(VERSION 3.1) is required to compile
# the examples to compile using conda's compiler packages
gsed -r -i -E 's#cmake_minimum_required\(VERSION [0-9]\.[0-9]#cmake_minimum_required(VERSION 3.1#gI' \
  $(find examples -name 'CMakeLists.txt')

mkdir geant4-build
cd geant4-build

cmake                                                          \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}                   \
      -DCMAKE_INSTALL_PREFIX=${PREFIX}                         \
      -DGEANT4_BUILD_CXXSTD=17                                 \
      -DGEANT4_USE_SYSTEM_EXPAT=ON                             \
      -DGEANT4_USE_SYSTEM_ZLIB=ON                              \
      -DGEANT4_INSTALL_DATADIR="${PREFIX}/share/Geant4/data"   \
      -DBUILD_SHARED_LIBS=ON                                   \
      -DGEANT4_INSTALL_EXAMPLES=ON                             \
      -DGEANT4_INSTALL_DATA=ON                                 \
      -DGEANT4_BUILD_MULTITHREADED=ON                          \
      -DGEANT4_USE_GDML=ON                                     \
      ${CMAKE_PLATFORM_FLAGS[@]} \
      ${SRC_DIR}

make -j${CPU_COUNT} ${VERBOSE_CM}
make install -j${CPU_COUNT}

# Print the contents of geant4.sh in case of problems
echo "Contents of ${PREFIX}/bin/geant4.sh is"
cat "${PREFIX}/bin/geant4.sh"

SETUP_SCRIPT_REGEX='export (G4.*)=.*/share/Geant4/data/([^ ]+).*'

# Add the post activate/deactivate scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
# Bash activation
grep 'export G4' "${PREFIX}/bin/geant4.sh" | \
  gsed -E 's#'"${SETUP_SCRIPT_REGEX}"'#export \1="${CONDA_PREFIX}/share/Geant4/data/\2"#g' \
  > "${PREFIX}/etc/conda/activate.d/activate-geant4.sh"
# Bash deactivation
grep 'export G4' "${PREFIX}/bin/geant4.sh" | \
  gsed -E 's#'"${SETUP_SCRIPT_REGEX}"'#unset \1#g' \
  > "${PREFIX}/etc/conda/deactivate.d/deactivate-geant4.sh"

# csh activation
grep 'export G4' "${PREFIX}/bin/geant4.sh" | \
  gsed -E 's#'"${SETUP_SCRIPT_REGEX}"'#setenv \1 "${CONDA_PREFIX}/share/Geant4/data/\2"#g' \
  > "${PREFIX}/etc/conda/activate.d/activate-geant4.csh"
# csh deactivation
grep 'export G4' "${PREFIX}/bin/geant4.sh" | \
  gsed -E 's#'"${SETUP_SCRIPT_REGEX}"'#unsetenv \1#g' \
  > "${PREFIX}/etc/conda/deactivate.d/deactivate-geant4.csh"

# fish activation
grep 'export G4' "${PREFIX}/bin/geant4.sh" | \
  gsed -E 's#'"${SETUP_SCRIPT_REGEX}"'#set -gx \1 "$CONDA_PREFIX/share/Geant4/data/\2"#g' \
  > "${PREFIX}/etc/conda/activate.d/activate-geant4.fish"
# fish deactivation
grep 'export G4' "${PREFIX}/bin/geant4.sh" | \
  gsed -E 's#'"${SETUP_SCRIPT_REGEX}"'#set -e \1#g' \
  > "${PREFIX}/etc/conda/deactivate.d/deactivate-geant4.fish"

# Remove the geant4.(c)sh scripts and replace with a dummy version
for suffix in sh csh; do
  rm "${PREFIX}/bin/geant4.${suffix}"
  cp "${RECIPE_DIR}/geant4-setup" "${PREFIX}/bin/geant4.${suffix}"
  chmod +x "${PREFIX}/bin/geant4.${suffix}"
done
