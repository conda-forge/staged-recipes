#!/bin/bash
set -e

# Backup method required on macOS, and supported on linux.

sed -i.bak -e 's@CMAKE_BUILD_WITH_INSTALL_RPATH FALSE@CMAKE_BUILD_WITH_INSTALL_RPATH TRUE@g' \
    root-source/cmake/modules/RootBuildOptions.cmake && rm $_.bak

sed -i.bak -e 's@include_directories(${LIBXML2_INCLUDE_DIR})@include_directories(${LIBXML2_INCLUDE_DIR} ${LIBXML2_INCLUDE_DIRS})@g' \
    root-source/io/xmlparser/CMakeLists.txt && rm $_.bak

mkdir build-dir
cd build-dir

if [ "$(uname)" == "Linux" ]; then
    cmake_args="-DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/toolchain.cmake -DCMAKE_AR=${GCC_AR} -DCLANG_DEFAULT_LINKER=${LD_GOLD} -DDEFAULT_SYSROOT=${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot -Dx11=ON -DRT_LIBRARY=${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib/librt.so"
else
    cmake_args="-Dcocoa=ON"
fi

CXXFLAGS=$(echo "${CXXFLAGS}" | echo "${CXXFLAGS}" | sed -E 's@-std=c\+\+[^ ]+@@g')
export CXXFLAGS

cmake -LAH \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    ${cmake_args} \
    -DCMAKE_C_COMPILER="${GCC}" \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_COMPILER="${GXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCLING_BUILD_PLUGINS=OFF \
    -Dexplicitlink=ON \
    -Dexceptions=ON \
    -Dfail-on-missing=ON \
    -Dgnuinstall=OFF \
    -Dshared=ON \
    -Dsoversion=ON \
    -Dbuiltin_clang=OFF \
    -Dbuiltin_glew=OFF \
    -Dbuiltin_xrootd=OFF \
    -Dbuiltin_davix=OFF \
    -Dbuiltin_llvm=OFF \
    -Dbuiltin_afterimage=OFF \
    -Drpath=ON \
    -Dcxx11=OFF \
    -Dcxx14=OFF \
    -Dcxx17=ON \
    -Dminuit2=ON \
    -Dgviz=ON \
    -Droofit=ON \
    -Dtbb=ON \
    -Dcastor=OFF \
    -Dgfal=OFF \
    -Dmysql=OFF \
    -Dopengl=OFF \
    -Doracle=OFF \
    -Dpgsql=OFF \
    -Dpythia6=OFF \
    -Dpythia8=OFF \
    -Dtesting=ON \
    -Droottest=OFF \
    ../root-source

make -j${CPU_COUNT}

make install

# Create symlinks so conda can find the Python bindings
test "$(ls "${PREFIX}"/lib/*.py | wc -l) = 4"
ln -s "${PREFIX}/lib/ROOT.py" "${SP_DIR}/"
ln -s "${PREFIX}/lib/_pythonization.py" "${SP_DIR}/"
ln -s "${PREFIX}/lib/cmdLineUtils.py" "${SP_DIR}/"
ln -s "${PREFIX}/lib/cppyy.py" "${SP_DIR}/"

test "$(ls "${PREFIX}"/lib/*/__init__.py | wc -l) = 2"
ln -s "${PREFIX}/lib/JsMVA/" "${SP_DIR}/"
ln -s "${PREFIX}/lib/JupyROOT/" "${SP_DIR}/"

test "$(ls "${PREFIX}"/lib/libPy* | wc -l) = 2"
ln -s "${PREFIX}/lib/libPyROOT.so" "${SP_DIR}/"
ln -s "${PREFIX}/lib/libPyMVA.so" "${SP_DIR}/"

# Remove the PCH as we will regenerate in the post install hook
rm "${PREFIX}/etc/allDict.cxx.pch"

# Fix broken symlinks that ROOT makes when installing
unlink "${PREFIX}/bin/clang++"
unlink "${PREFIX}/bin/clang-cl"
unlink "${PREFIX}/bin/clang-cpp"

# Add the post activate/deactivate scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/activate-root.sh"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/deactivate-root.sh"
