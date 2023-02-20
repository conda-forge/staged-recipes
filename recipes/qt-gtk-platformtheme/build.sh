set -ex

# This creates a standalone shared library that mimics the results
# of configuring qt with the flag `-gtk`
#
# By creating this standalone package, we simplify the proces of
# rebuilding qt due to requiring fewer dependencies for the main package
# requiring fewer bumps when the version changes.
# The CMakeLists.txt file was inspired by the one from Fedora
# https://github.com/FedoraQt/QGnomePlatform
# and is likely to work for qt6
cp -R src/plugins/platformthemes/gtk3/ qgtk3
cd qgtk3
cp ${RECIPE_DIR}/gtk_theme_CMakeLists.txt CMakeLists.txt

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE="Release"    \
    -DCMAKE_PREFIX_PATH=${PREFIX}   \
    ..

make -j${CPU_COUNT}
make install
