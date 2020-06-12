cd opensim-core-source
cd ..
mkdir build_dep
cd build_dep
cmake ../opensim-moco-source/dependencies -G Ninja -LAH ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_INSTALL_PREFIX=../opensim_dependencies_install ^
    -DSUPERBUILD_simbody=OFF ^
    -DSUPERBUILD_spdlog=OFF ^
    -DSUPERBUILD_docopt=ON
ninja

cd ..
mkdir build
cd build
echo "DEBUG %CONDA_PREFIX%"
cmake ../opensim-moco-source -G Ninja -LAH ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DOPENSIM_DEPENDENCIES_DIR=../opensim_dependencies_install ^
    -DSIMBODY_HOME="%CONDA_PREFIX%" ^
    -DOPENSIM_C3D_PARSER=ezc3d ^
    -DBUILD_PYTHON_WRAPPING=ON ^
    -DBUILD_TESTING=OFF ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DOPENSIM_INSTALL_UNIX_FHS=ON ^
ninja
ninja doxygen
ninja install

