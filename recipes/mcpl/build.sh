#!/bin/bash
set -x
set -e

mkdir -p build
cd build

#Config (INSTALL_PY=OFF since we handle mcpl/pymcpltool installation via pip below).
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    "${SRC_DIR}/src" \
    -DBUILD_SHARED_LIBS=ON \
    -DMCPL_NOTOUCH_CMAKE_BUILD_TYPE=ON \
    -DMODIFY_RPATH=OFF \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=OFF \
    -DINSTALL_PY=OFF \
    -DPython3_EXECUTABLE="$PYTHON" \
    ${CMAKE_ARGS}

make -j${CPU_COUNT:-1}
make install

#Note: There is no "make test" or "make ctest" functionality for MCPL
#      yet. If it appears in the future, we should add it here.

#Install the python module via pip:

THEMCPLVERSION=$(cat "${SRC_DIR}/src/VERSION")
mkdir -p mcpl_pypkg/mcpl
cp "${SRC_DIR}"/src/src/python/mcpl.py ./mcpl_pypkg/mcpl/__init__.py

cat <<EOF > ./mcpl_pypkg/setup.py
from setuptools import setup
setup( name = 'mcpl',
       version = '$THEMCPLVERSION'.strip(),
       author = "MCPL developers (Thomas Kittelmann, et al.)",
       license = "CC0 1.0 Universal",
       description='Monte Carlo Particle Lists : MCPL',
       url='https://mctools.github.io/mcpl',
       keywords='montecarlo,science',
       python_requires='>=3.6, <4',
       install_requires=['numpy'],
       entry_points = { 'console_scripts': ['pymcpltool = mcpl:main'] },
       long_description='Utilities and API for accessing MCPL (.mcpl) files. MCPL is a binary format with lists of particle state information, for interchanging and reshooting events between various Monte Carlo simulation applications.',
)
EOF

$PYTHON -m pip install ./mcpl_pypkg/ --no-deps -vv

cd ..
