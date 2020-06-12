cd opensim-core-source
cd ..
mkdir build_dep
cd build_dep
cmake ../opensim-core-source/dependencies -G Ninja -LAH ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_INSTALL_PREFIX=../opensim_dependencies_install ^
    -DSUPERBUILD_simbody=OFF ^
    -DSUPERBUILD_spdlog=OFF ^
    -DSUPERBUILD_docopt=ON ^
    -DSUPERBUILD_BTK=OFF
ninja

cd ..
mkdir build
cd build
cmake ../opensim-core-source -G Ninja -LAH ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DOPENSIM_DEPENDENCIES_DIR=../opensim_dependencies_install ^
    -DSIMBODY_HOME="%LIBRARY_PREFIX%" ^
    -DBUILD_PYTHON_WRAPPING=ON ^
    -DBUILD_TESTING=OFF ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DOPENSIM_INSTALL_UNIX_FHS=ON
REM    -DOPENSIM_C3D_PARSER=ezc3d ^
ninja
ninja doxygen
ninja install

