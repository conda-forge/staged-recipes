#!/bin/bash

set -x

cd ${SRC_DIR}

mkdir -p standalone-build
pushd standalone-build
  cmake -DITKPythonPackage_BUILD_PYTHON:PATH=0 -G Ninja ../
  ninja
popd

source_path=${SRC_DIR}/standalone-build/ITKs
build_path=${SRC_DIR}/ITK-build
build_type=Release

mkdir -p ${build_path}
pushd ${build_path}
cmake -DCMAKE_BUILD_TYPE:STRING=${build_type} \
  -DITK_SOURCE_DIR:PATH=${source_path} \
  -DITK_BINARY_DIR:PATH=${build_path} \
  -DBUILD_TESTING:BOOL=OFF \
  -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON} \
  -DWRAP_ITK_INSTALL_COMPONENT_IDENTIFIER:STRING=PythonWheel \
  -DWRAP_ITK_INSTALL_COMPONENT_PER_MODULE:BOOL=ON \
  -DPY_SITE_PACKAGES_PATH:PATH="." \
  -DITK_BUILD_DEFAULT_MODULES:BOOL=OFF \
  -DITK_WRAP_unsigned_short:BOOL=ON \
  -DITK_WRAP_double:BOOL=ON \
  -DITK_LEGACY_SILENT:BOOL=ON \
  -DITK_WRAP_PYTHON:BOOL=ON \
  -DITK_WRAP_PYTHON_LEGACY:BOOL=OFF \
  -DITK_WRAP_DOC:BOOL=ON \
  -G Ninja \
  ${source_path} \
&& ninja \
|| exit 1
popd


setup_py_configure=${SRC_DIR}/scripts/setup_py_configure.py
# Possible package names are defined in ${SRC_DIR}/scripts/WHEEL_NAMES.txt
for wheel_name in itk-core; do
  # Configure setup.py
  ${PYTHON} ${setup_py_configure} ${wheel_name}
  # Generate wheel
  ${PYTHON} setup.py install --build-type ${build_type} -G Ninja -- \
    -DITK_SOURCE_DIR:PATH=${source_path} \
    -DITK_BINARY_DIR:PATH=${build_path} \
    -DITKPythonPackage_ITK_BINARY_REUSE:BOOL=ON \
    -DITKPythonPackage_WHEEL_NAME:STRING=${wheel_name} \
    -DITK_WRAP_unsigned_short:BOOL=ON \
    -DITK_WRAP_double:BOOL=ON \
    -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON} \
    -DITK_WRAP_DOC:BOOL=ON \
    || exit 1
  # Cleanup
  ${PYTHON} setup.py clean
done
