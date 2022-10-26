rm -rf build
mkdir build
cd build

if [[ $build_platform == "osx-64" ]]; then
    set TBB_SWITCH=OFF
else
    set TBB_SWITCH=ON
fi
if [[ $PKG_NAME == "libthermo" ]]; then
    cmake .. ${CMAKE_ARGS}              \
        -GNinja                         \
        -DCMAKE_INSTALL_PREFIX=$PREFIX  \
        -DCMAKE_PREFIX_PATH=$PREFIX     \
        -DCMAKE_BUILD_TYPE="Release"    \
        -DLIBTHERMO_USE_XTENSOR=ON      \
        -DXTENSOR_USE_XSIMD=ON          \
        -DXTENSOR_USE_TBB=ON
elif [[ $PKG_NAME == "pythermo" ]]; then
    cmake .. ${CMAKE_ARGS}              \
        -GNinja                         \
        -DCMAKE_PREFIX_PATH=$PREFIX     \
        -DCMAKE_INSTALL_PREFIX=$PREFIX  \
        -DCMAKE_BUILD_TYPE="Release"    \
        -DPython_EXECUTABLE=$PYTHON     \
        -DLIBTHERMO_USE_XTENSOR=ON      \
        -DXTENSOR_USE_XSIMD=ON          \
        -DXTENSOR_USE_TBB=$TBB_SWITCH   \
        -DBUILD_PY=ON
fi

ninja

ninja install

if [[ $PKG_NAME == "pythermo" ]]; then
    cd ../pythermo
    rm -rf build
    $PYTHON -m pip install . --no-deps -vv
    find pythermo/pythermo_core* -type f -print0 | xargs -0 rm -f --
fi
