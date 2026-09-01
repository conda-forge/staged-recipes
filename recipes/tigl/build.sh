
declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*linux.* ]]; then
    CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi


mkdir -p build
cd build

# Configure step
# Note: PythonOCC_SOURCE_DIR is explicitly pointed at the pythonocc-core SWIG sources vendored
# into thirdparty/pythonocc-core via the second `source:` entry in recipe.yaml (an intermediate
# solution until the pythonocc-core-feedstock ships these files directly). It must be set here
# rather than left to tigl's own cmake/FindPythonOCC.cmake to auto-detect, because
# cross-linux.cmake sets CMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY, which would make find_path()
# restrict its search to $PREFIX/sysroot and never see anything under $SRC_DIR.
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=$PREFIX \
 -DCMAKE_BUILD_TYPE=Release \
  ${CMAKE_PLATFORM_FLAGS[@]} \
 -DCMAKE_PREFIX_PATH=$PREFIX \
 -DTIGL_CREATOR=ON \
 -DTIGL_CONCAT_GENERATED_FILES=OFF \
 -DTIGL_BINDINGS_PYTHON_INTERNAL=ON \
 -DPython3_FIND_STRATEGY=LOCATION \
 -DPython3_FIND_FRAMEWORK=NEVER \
 -DPythonOCC_SOURCE_DIR=$SRC_DIR/thirdparty/pythonocc-core \
 -DBUNDLE_APPLE=OFF \
 ..


# Build step
ninja

# Install step
ninja install

# tigl's own `ninja install` now installs the python bindings straight into site-packages
# (bindings/CMakeLists.txt computes $SP_DIR via Python's sysconfig and installs there directly,
# see patches/fix-python-site-packages-detection.patch), so no manual relocation is needed here.
python $RECIPE_DIR/fixosxload.py $SP_DIR/tigl3/tigl3wrapper.py libtigl3

# The egg-info file is necessary because some packages
# might require tigl3 in their setup.py.
# See https://setuptools.readthedocs.io/en/latest/pkg_resources.html#workingset-objects

cat > $SP_DIR/tigl3-$PKG_VERSION.egg-info <<FAKE_EGG
Metadata-Version: 2.1
Name: tigl3
Version: $PKG_VERSION
Summary: The TiGL Geometry Library to process aircraft geometries in pre-design
Platform: UNKNOWN
FAKE_EGG