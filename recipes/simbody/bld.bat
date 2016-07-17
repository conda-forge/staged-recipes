mkdir build
cd build
cmake -G "%CMAKE_GENERATOR%" -DBUILD_VISUALIZER=OFF -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
cmake --build . --target install --config Release -- /verbosity:quiet
REM NOTE: Run just one test here in the build directory to make sure things
REM built correctly. This cannot be specified in the meta.yml:test section
REM because it won't be run in the build directory.
ctest --build-config Release --output-on-failure -R TestMassMatrix
