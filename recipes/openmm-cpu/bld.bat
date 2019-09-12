mkdir build
cd build

cmake.exe .. -G "NMake Makefiles JOM" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DFFTW_INCLUDES="%LIBRARY_INC%" ^
    -DFFTW_LIBRARY="%LIBRARY_LIB%/fftw3f.lib" ^
    -DBUILD_TESTING=OFF ^
    -DOPENMM_BUILD_OPENCL_LIB=OFF ^
    -DOPENMM_BUILD_DRUDE_OPENCL_LIB=OFF ^
    -DOPENMM_BUILD_RPMD_OPENCL_LIB=OFF ^
    || goto :error
jom install || goto :error
jom PythonInstall || goto :error
jom install || goto :error


mkdir %LIBRARY_PREFIX%\share\openmm || goto :error
move %LIBRARY_PREFIX%\examples %LIBRARY_PREFIX%\share\openmm || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
