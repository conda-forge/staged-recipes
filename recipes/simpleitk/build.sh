#!/bin/bash

BUILD_DIR=${SRC_DIR}/build

mkdir ${BUILD_DIR}
cd ${BUILD_DIR}

PYTHON_INCLUDE_DIR=$(${PYTHON} -c 'import sysconfig;print("{0}".format(sysconfig.get_path("platinclude")))')
PYTHON_LIBRARY=$(${PYTHON} -c 'import sysconfig;print("{0}/{1}".format(*map(sysconfig.get_config_var, ("LIBDIR", "LDLIBRARY"))))')

cmake \
    -G Ninja \
    -D "CMAKE_CXX_FLAGS:STRING=-fvisibility=hidden -fvisibility-inlines-hidden ${CXXFLAGS}" \
    -D "CMAKE_C_FLAGS:STRING=-fvisibility=hidden ${CFLAGS}" \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D "CMAKE_FIND_ROOT_PATH:PATH=${PREFIX}" \
    -D "CMAKE_FIND_ROOT_PATH_MODE_INCLUDE:STRING=ONLY" \
    -D "CMAKE_FIND_ROOT_PATH_MODE_LIBRARY:STRING=ONLY" \
    -D "CMAKE_FIND_ROOT_PATH_MODE_PROGRAM:STRING=NEVER" \
    -D "CMAKE_FIND_ROOT_PATH_MODE_PACKAGE:STRING=ONLY" \
    -D "CMAKE_FIND_FRAMEWORK:STRING=NEVER" \
    -D "CMAKE_FIND_APPBUNDLE:STRING=NEVER" \
    -D "CMAKE_INSTALL_PREFIX=${PREFIX}" \
    -D "CMAKE_PROGRAM_PATH=${BUILD_PREFIX}" \
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON \
    -D SimpleITK_BUILD_STRIP:BOOL=ON \
    -D BUILD_SHARED_LIBS:BOOL=OFF \
    -D BUILD_TESTING:BOOL=OFF \
    -D SimpleITK_PYTHON_USE_VIRTUALENV:BOOL=OFF \
    -D "PYTHON_EXECUTABLE:FILEPATH=${PYTHON}" \
    -D "PYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}" \
    -D "PYTHON_LIBRARY:PATH=${PYTHON_LIBRARY_DIR}" \
    "${SRC_DIR}"/Wrapping/Python

cmake --build . --config Release
${PYTHON} Packaging/setup.py install
