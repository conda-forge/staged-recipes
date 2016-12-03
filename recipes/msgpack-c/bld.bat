mkdir build
cd build

IF "%ARCH%"=="32" (
    SET ENABLE32=YES
) ELSE (
    SET ENABLE32=NO
)

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_CXX_FLAGS='"/D_VARIADIC_MAX=10 /EHsc"' ^
    -DBoost_INCLUDE_DIRS=%LIBRARY_PREFIX%\include ^
    -DMSGPACK_BOOST_DIR=%LIBRARY_PREFIX%\include ^
    -DMSGPACK_BOOST=YES ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DMSGPACK_32BIT=%ENABLE32% ^
    ..

cmake --build . --config Release
cmake --build . --config Release --target install
