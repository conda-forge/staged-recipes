#!/usr/bin/env bash
set -ex

INTERFACES=( "serial" )
if [ "${mpi}" != "nompi" ]; then
  INTERFACES+=( "mpi" )
  if [ "${mpi}" == "openmpi" ]; then
    export OMPI_MCA_plm=isolated
  fi
fi

cmake_options=( ${CMAKE_ARGS} )
meson_options=( ${MESON_ARGS} )
meson_fflags="-ffree-line-length-none"
for interface in ${INTERFACES[@]}; do
  RUN_PREFIX=""
  if [[ "${interface}" == "mpi" ]]; then
    RUN_PREFIX="mpirun -np 2"
  fi
  # Invoking installed library via CMake
  BUILD_DIR="_build_cmake_${interface}"
  cmake "${cmake_options[@]}" -GNinja -B ${BUILD_DIR} -S test/export/${interface}
  cmake --build ${BUILD_DIR}
  ${RUN_PREFIX} ${BUILD_DIR}/app/testapp
  ${RUN_PREFIX} ${BUILD_DIR}/app/testapp_fpp
  ${RUN_PREFIX} ${BUILD_DIR}/app/testapp_fypp

  # Invoking installed library via Meson
  BUILD_DIR="_build_meson_${interface}"
  FFLAGS="${meson_fflags}"\
    meson setup "${meson_options[@]}" --wrap-mode nofallback ${BUILD_DIR} test/export/${interface}
  ninja -j1 -v -C ${BUILD_DIR}
  ${RUN_PREFIX} ${BUILD_DIR}/testapp
  ${RUN_PREFIX} ${BUILD_DIR}/testapp_fpp
done
