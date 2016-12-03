mkdir build
cd build

IF "%ARCH%"=="32" (
    SET COMPILE_FLAGS="/wd4267"
) ELSE (
    SET COMPILE_FLAGS=""
)

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_CXX_FLAGS='"/D_VARIADIC_MAX=10 /EHsc"' ^
    -DBoost_INCLUDE_DIRS=%LIBRARY_PREFIX%\include ^
    -DMSGPACK_BOOST_DIR=%LIBRARY_PREFIX%\include ^
    -DMSGPACK_BOOST=YES ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_CXX_FLAGS="%COMPILE_FLAGS%" ^
    -DCMAKE_C_FLAGS="%COMPILE_FLAGS%" ^
    ..

cmake --build . --config Release
cmake --build . --config Release --target install
