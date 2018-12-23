#!/bin/bash

declare -a CMAKE_EXTRA_ARGS
if [[ ${target_platform} =~ linux-* ]]; then
  echo "Nothing special for linux"
elif [[ ${target_platform} == osx-64 ]]; then
  CMAKE_EXTRA_ARGS+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
else
  echo "target_platform not known: ${target_platform}"
  exit 1
fi

mkdir build || true
pushd build

  cmake .. -LAH                                                             \
    -DCMAKE_BUILD_TYPE="Release"                                            \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"                                      \
    -DCMAKE_INSTALL_LIBDIR=lib                                              \
    -DCMAKE_SKIP_RPATH=ON                                                   \
    -DCMAKE_AR="${AR}"                                                      \
    -DCMAKE_LINKER="${LD}"                                                  \
    -DCMAKE_NM="${NM}"                                                      \
    -DCMAKE_OBJCOPY="${OBJCOPY}"                                            \
    -DCMAKE_OBJDUMP="${OBJDUMP}"                                            \
    -DCMAKE_RANLIB="${RANLIB}"                                              \
    -DCMAKE_STRIP="${STRIP}"                                                \
    -DLIEF_PYTHON_API=ON                                                    \
    -DLIEF_INSTALL_PYTHON=ON                                                \
    -DPYTHON_EXECUTABLE="${PYTHON}"                                         \
    -DPYTHON_INCLUDE_DIR:PATH=$(${PYTHON} -c 'from sysconfig import get_paths; print(get_paths()["include"])')  \
    -DPYTHON_LIBRARIES="${PREFIX}"/lib/libpython${PY_VER}${SHLIB_EXT}       \
    -DPYTHON_LIBRARY="${PREFIX}"/lib/libpython${PY_VER}${SHLIB_EXT}         \
    -D_PYTHON_LIBRARY="${PREFIX}"/lib/libpython${PY_VER}${SHLIB_EXT}        \
    -DPYTHON_VERSION=${PY_VER}                                              \
    "${CMAKE_EXTRA_ARGS[@]}"

  if [[ ! $? ]]; then
    echo "configure failed with $?"
    exit 1
  fi

  make -j${CPU_COUNT} ${VERBOSE_CM}
  make install ${VERBOSE_CM}
  pushd api/python
    find ${SP_DIR}
    ${PYTHON} setup.py install --single-version-externally-managed --record=record.txt
    ${INSTALL_NAME_TOOL:-install_name_tool} -id @rpath/_pylief.cpython-${CONDA_PY}m-darwin.so ${SP_DIR}/_pylief.cpython-${CONDA_PY}m-darwin.so
  popd
popd
[[ -d "${PREFIX}"/share/LIEF/examples ]] && rm -rf "${PREFIX}"/share/LIEF/examples/
