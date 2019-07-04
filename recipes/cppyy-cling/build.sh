#!/bin/bash

# Much of this file (and the entire recipe in fact) has been taken from the
# root-feedstock.

export STDCXX=17
export VERBOSE=1

# Manually set the deployment_target
# May not be very important but nice to do
OLDVERSIONMACOS='${MACOSX_VERSION}'
sed -i -e "s@${OLDVERSIONMACOS}@${MACOSX_DEPLOYMENT_TARGET}@g" src/cmake/modules/SetUpMacOS.cmake

declare -a CMAKE_PLATFORM_FLAGS
if [ "$(uname)" == "Linux" ]; then
    CMAKE_PLATFORM_FLAGS+=("-DCMAKE_AR=${GCC_AR}")
    CMAKE_PLATFORM_FLAGS+=("-DCLANG_DEFAULT_LINKER=${LD_GOLD}")
    CMAKE_PLATFORM_FLAGS+=("-DDEFAULT_SYSROOT=${PREFIX}/${HOST}/sysroot")
    CMAKE_PLATFORM_FLAGS+=("-DRT_LIBRARY=${PREFIX}/${HOST}/sysroot/usr/lib/librt.so")

    # Hide symbols from LLVM/clang to avoid conflicts with other libraries
    for lib_name in $(ls $PREFIX/lib | grep -E 'lib(LLVM|clang).*\.a'); do
        export CXXFLAGS="${CXXFLAGS} -Wl,--exclude-libs,${lib_name}"
    done
    echo "CXXFLAGS is now '${CXXFLAGS}'"
else
    CMAKE_PLATFORM_FLAGS+=("-Dcocoa=ON")
    CMAKE_PLATFORM_FLAGS+=("-DCLANG_RESOURCE_DIR_VERSION='5.0.0'")

    # Print out and possibly fix SDKROOT (Might help Azure)
    echo "SDKROOT is: '${SDKROOT}'"
    echo "CONDA_BUILD_SYSROOT is: '${CONDA_BUILD_SYSROOT}'"
    export SDKROOT="${CONDA_BUILD_SYSROOT}"
fi

# Remove -std=c++XX from build ${CXXFLAGS}
CXXFLAGS=$(echo "${CXXFLAGS}" | sed -E 's@-std=c\+\+[^ ]+@@g')
export CXXFLAGS

# The cross-linux toolchain breaks find_file relative to the current file
# Patch up with sed
sed -i -E 's#(ROOT_TEST_DRIVER RootTestDriver.cmake PATHS \$\{THISDIR\} \$\{CMAKE_MODULE_PATH\} NO_DEFAULT_PATH)#\1 CMAKE_FIND_ROOT_PATH_BOTH#g' \
    src/cmake/modules/RootNewMacros.cmake

export CMAKE_ROOT_FLAGS=${CMAKE_PLATFORM_FLAGS[@]}

# Some flags that root-feedstock sets. They probably don't hurt when building cppyy (probably much of this is already covered by the -Dminimal=ON that setup.py sets...):
CMAKE_ROOT_FLAGS="${CMAKE_ROOT_FLAGS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON -DCLING_BUILD_PLUGINS=OFF -DPYTHON_EXECUTABLE=\"${PYTHON}\" -DTBB_ROOT_DIR=\"${PREFIX}\" -Dexplicitlink=ON -Dexceptions=ON -Dfail-on-missing=ON -Dgnuinstall=OFF -Dshared=ON -Dsoversion=ON -Dbuiltin-glew=OFF -Dbuiltin_xrootd=OFF -Dbuiltin_davix=OFF -Dbuiltin_afterimage=OFF -Drpath=ON -DCMAKE_CXX_STANDARD=17 -Dcastor=off -Dgfal=OFF -Dmysql=OFF -Doracle=OFF -Dpgsql=OFF -Dpythia6=OFF -Droottest=OFF"
# Use conda-forge's clang & llvm
CMAKE_ROOT_FLAGS="${CMAKE_ROOT_FLAGS} -Dbuiltin_llvm=OFF -Dbuiltin_clang=OFF"

python -m pip install . --no-deps -vv
