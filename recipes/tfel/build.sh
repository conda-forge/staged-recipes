# adding a flag for better control of the visibility of some symbols

CXXFLAGS="${CXXFLAGS} -fvisibility-inlines-hidden"

# adding python includes to CXXFLAGS which contains the path
# to `boost/python` but not to the `python` headers

file=$(mktemp)
cat > $file << EOF
#!$PYTHON
from distutils import sysconfig
if sysconfig.get_python_inc() != sysconfig.get_python_inc(plat_specific=True) :
    print('-I' + sysconfig.get_python_inc() + '-I' + sysconfig.get_python_inc(plat_specific=True))
else :
    print('-I' + sysconfig.get_python_inc())
EOF
PYTHON_INCLUDES=$(python $file)
CXXFLAGS="${CXXFLAGS} ${PYTHON_INCLUDES}"


# calling cmake
# The use of the USE_EXTERNAL_COMPILER_FLAGS is here because
# the Boost_INCLUDEDIRS and PYTHON_INCLUDEDIRS, while properly set
# are discarded by cmake, i.e. the following statement has no effect:
# `include_directories("${Boost_INCLUDEDIRS}")`
# `include_directories("${PYTHON_INCLUDEDIRS}")`
# To circumvent this issue, we use the CXXFLAGS variable, as defined by
# `conda-build` (hence the USE_EXTERNAL_COMPILER_FLAGS).
cmake "${SRC_DIR}" -G "${CMAKE_GENERATOR}"         \
      -DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}" \
      -DCMAKE_BUILD_TYPE=Release\
      -DUSE_EXTERNAL_COMPILER_FLAGS=ON\
      -Denable-developer-warnings=OFF\
      -Denable-random-tests=OFF\
      -Dlocal-castem-header=ON\
      -Denable-fortran=ON\
      -Denable-python=ON\
      -Denable-python-bindings=ON\
      -DBOOST_ROOT="${PREFIX}"\
      -DBoost_NO_SYSTEM_PATHS=ON\
      -DBoost_USE_STATIC_LIBS=OFF\
      -DBoost_NO_BOOST_CMAKE=ON\
      -Denable-java=OFF\
      -Denable-aster=ON\
      -Denable-abaqus=ON\
      -Denable-calculix=ON\
      -Denable-comsol=ON\
      -Denable-diana-fea=ON\
      -Denable-ansys=ON\
      -Denable-europlexus=ON\
      -Denable-zmat=OFF\
      -Denable-cyrano=ON\
      -Denable-lsdyna=ON\
      -Denable-cadna=OFF\
      -Denable-website=OFF\
      -Denable-reference-doc=OFF\
      -Denable-doxygen-doc=OFF\
      -Denable-portable-build=ON\
      -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF\
      -DCMAKE_INSTALL_PREFIX="${PREFIX}"

cmake --build . --target all
cmake --build . --target install
