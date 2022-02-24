cd opensim-core-source
cd ..
mkdir build_dep
cd build_dep
cmake ../opensim-core-source/dependencies -G Ninja -LAH ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_INSTALL_PREFIX=../opensim_dependencies_install ^
    -DSUPERBUILD_spdlog=ON ^
    -DSUPERBUILD_colpack=ON ^
    -DSUPERBUILD_docopt=OFF ^
    -DSUPERBUILD_ezc3d=OFF ^
    -DSUPERBUILD_simbody=OFF ^
    -DSUPERBUILD_casadi=OFF
ninja

cd ..
mkdir build
cd build
cmake ../opensim-core-source -G Ninja -LAH ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DOPENSIM_DEPENDENCIES_DIR=../opensim_dependencies_install ^
    -DCMAKE_PREFIX_PATH="%PREFIX%" ^
    -DSIMBODY_HOME="%LIBRARY_PREFIX%" ^
    -DColPack_DIR=../opensim_dependencies_install/colpack/cmake ^
    -DBUILD_PYTHON_WRAPPING=ON ^
    -DBUILD_TESTING=OFF ^
    -DOPENSIM_BUILD_INDIVIDUAL_APPS=OFF ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DOPENSIM_INSTALL_UNIX_FHS=ON ^
    -DOPENSIM_WITH_CASADI=OFF ^
    -DOPENSIM_WITH_TROPTER=ON ^
    -DOPENSIM_PYTHON_CONDA=ON
ninja
ninja doxygen
ninja install

