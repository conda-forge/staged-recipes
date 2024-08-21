#!/usr/bin/env bash

set -euxo pipefail

# C lib
bash ./build.sh -shared

# Install
mkdir -p "${PREFIX}"/lib
if [[ "${target_platform}" == osx-* ]]; then
  cp libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib
  ln -s "${PREFIX}"/lib/libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib/libblst.dylib
  ln -s "${PREFIX}"/lib/libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib/libblst."${PKG_VERSION}".dylib
else
  cp libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib
  ln -s "${PREFIX}"/lib/libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib/libblst.so
  ln -s "${PREFIX}"/lib/libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib/libblst.so."${PKG_VERSION}"
fi

# Python bindings
pushd bindings/python
  export CXX="${CXX}"
  ./run.me

  PY_IMPL=$(${PYTHON} -c "import sysconfig; print(sysconfig.get_config_var('IMPLEMENTATION').lower())")
  PY_VER=$(${PYTHON} -c "import sysconfig; print(sysconfig.get_config_var('py_version_nodot'))")
  PY_HOST=$(${PYTHON} -c "import sysconfig; print(f'{sysconfig.get_platform().split(\"-\")[1]}-{sysconfig.get_platform().split(\"-\")[0]}')")

  # Install Python bindings to site-packages
  mkdir -p "${PREFIX}/lib/python${PY_VER}/site-packages/blst"
  if [[ "${target_platform}" == osx-* ]]; then
    # cp _blst."${PY_IMPL}-${PY_VER}-${PY_HOST}"*.dylib "${PREFIX}/lib/python${PY_VER}/site-packages/blst"
    cp _blst*.dylib "${PREFIX}/lib/python${PY_VER}/site-packages/blst"
  else
    # cp _blst."${PY_IMPL}-${PY_VER}-${PY_HOST}"*.so "${PREFIX}/lib/python${PY_VER}/site-packages/blst/"
    cp _blst*.so "${PREFIX}/lib/python${PY_VER}/site-packages/blst/"
  fi
  cp blst.py "${PREFIX}/lib/python${PY_VER}/site-packages/blst"
  touch "${PREFIX}/lib/python${PY_VER}/site-packages/blst/__init__.py"
popd