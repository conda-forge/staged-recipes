mkdir build
cd build

cmake ^
    -GNinja ^
    -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF ^
    -DGTSAM_USE_SYSTEM_EIGEN=ON ^
    -DGTSAM_INSTALL_CPPUNITLITE=OFF ^
    -DGTSAM_BUILD_PYTHON=ON ^
    -DBoost_USE_STATIC_LIBS=OFF ^
    -DBOOST_ROOT="%LIBRARY_PREFIX%" ^
    -DBoost_NO_SYSTEM_PATHS=ON ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DPython3_EXECUTABLE=%PYTHON% ^
    %SRC_DIR%

ninja install

@rem ninja check
