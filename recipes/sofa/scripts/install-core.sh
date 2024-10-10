#!/bin/bash
set -ex

cd build

if [[ "$PKG_NAME" == "libsofa" ]]; then
    # only the libraries (don't copy CMake metadata)
    cp -R temp_prefix/lib/libSofa*${SHLIB_EXT}* $PREFIX/lib

    # and plugins libraries
    cd temp_prefix/plugins
    for plugin_dir in */ ; do
        mkdir -p $PREFIX/plugins/$plugin_dir/lib
        cp -R $plugin_dir/lib/*${SHLIB_EXT}* $PREFIX/plugins/$plugin_dir/lib
    done
    cd ../..

    # Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
    # This will allow them to be run on environment activation.
    for CHANGE in "activate" "deactivate"
    do
        mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
        cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    done

elif [[ "$PKG_NAME" == "sofa-devel" ]]; then
    # headers
    cp -R temp_prefix/include/. $PREFIX/include
    # CMake metadata
    cp -R temp_prefix/lib/cmake/Sofa* $PREFIX/lib/cmake
    # and plugins
    cd temp_prefix/plugins
    for plugin_dir in */ ; do
        # headers
        mkdir -p $PREFIX/plugins/$plugin_dir/include
        cp -R $plugin_dir/include/. $PREFIX/plugins/$plugin_dir/include
        # CMake metadata
        mkdir -p $PREFIX/plugins/$plugin_dir/lib/cmake
        cp -R $plugin_dir/lib/cmake $PREFIX/plugins/$plugin_dir/lib/cmake
    done
    cd ../..
else
  echo "Invalid package to install"
  exit 1
fi
