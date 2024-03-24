mkdir build
cd build

echo "Old nanobind_DIR=$SP_DIR/nanobind/cmake"

export PYTHON_VERSION=`$PYTHON -c "import sys; print('%i.%i' % (sys.version_info[0:2]))"`
echo "Using Python ${PYTHON_VERSION}"
# Fix up SP_DIR which for some reason might contain a path to a wrong Python version
FIXED_SP_DIR=$(echo $SP_DIR | sed -E "s/python[0-9]+\.[0-9]+/python$PYTHON_VERSION/")
echo "Fixed nanobind_DIR=$FIXED_SP_DIR/nanobind/cmake"

export CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS -D_LIBCPP_DISABLE_AVAILABILITY"

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -Dnanobind_DIR=$FIXED_SP_DIR/nanobind/cmake \
      -DUSE_PYTHON=1

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
