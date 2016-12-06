mkdir build
cd build

SET GENERATOR=%CMAKE_GENERATOR%

IF "%ARCH%"=="32" (
    SET EXTRA_COMPILE_FLAGS=
) ELSE (
    SET EXTRA_COMPILE_FLAGS=/wd4267 /wd4244
    IF "%CONDA_PY%"=="27" SET GENERATOR=NMake Makefiles
)

IF "%CONDA_PY%"=="35" (
    SET ENABLE_CXX11=YES
) ELSE (
    SET ENABLE_CXX11=NO
)

cmake ^
    -G "%GENERATOR%" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_CXX_FLAGS='"/D_VARIADIC_MAX=10 /EHsc %EXTRA_COMPILE_FLAGS%"' ^
    -DCMAKE_C_FLAGS="%COMPILE_FLAGS%" ^
    -DBoost_INCLUDE_DIRS=%LIBRARY_PREFIX%\include ^
    -DMSGPACK_BOOST_DIR=%LIBRARY_PREFIX%\include ^
    -DMSGPACK_BOOST=YES ^
    -DMSGPACK_CXX11=%ENABLE_CXX11% ^
    -DGTEST_LIBRARY=%LIBRARY_BIN%\gtest_dll.lib ^
    -DGTEST_MAIN_LIBRARY=%LIBRARY_BIN%\gtest_main.lib ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..

cmake --build . --config Release
cmake --build . --config Release --target install

ctest

cd "%LIBRARY_PREFIX%/lib"
ren msgpackc.lib msgpackc_static.lib
ren msgpackc_import.lib msgpackc.lib
