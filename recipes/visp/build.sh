#!/bin/sh

set -ex

# Hints OGRE to find its CMake module file
if [[ "$target_platform" == linux* ]]; then
    OGRE_DIR="${PREFIX}/lib/OGRE/cmake"
elif [[ "$target_platform" == osx* ]]; then
    OGRE_DIR="${PREFIX}/cmake"
fi


if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

    # Workaround for https://github.com/conda-forge/tk-feedstock/issues/15
    # Taken from https://github.com/conda-forge/ambertools-feedstock/blob/2ccbcde9a96c90da31ed199e64c33a4e5f64695c/recipe/build.sh#L40-L51
    #  In MacOS, `tk` ships some X11 headers that interfere with the X11 libraries
    #  1) delete clobbered X11 headers (mix of tk and xorg)
    rm -rf ${PREFIX}/include/X11/{DECkeysym,HPkeysym,Sunkeysym,X,XF86keysym,Xatom,Xfuncproto}.h
    rm -rf ${PREFIX}/include/X11/{ap_keysym,keysym,keysymdef,Xlib,Xutil,cursorfont}.h
    #  2) Reinstall Xorg dependencies
    #     We temporarily disable the (de)activation scripts because they fail otherwise
    set +u
    mv ${BUILD_PREFIX}/etc/conda/{activate.d,activate.d.bak}
    mv ${BUILD_PREFIX}/etc/conda/{deactivate.d,deactivate.d.bak}
    conda install --yes --no-deps --force-reinstall -p ${PREFIX} xorg-xproto xorg-libx11
    mv ${BUILD_PREFIX}/etc/conda/{activate.d.bak,activate.d}
    mv ${BUILD_PREFIX}/etc/conda/{deactivate.d.bak,deactivate.d}
    set -u
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -DOGRE_DIR=${OGRE_DIR} \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTS=ON

# build
cmake --build . --parallel ${CPU_COUNT}

# install 
cmake --build . --parallel ${CPU_COUNT} --target install

# test
ctest --parallel ${CPU_COUNT}