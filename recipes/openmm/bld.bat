mkdir build
cd build

cmake.exe .. -G "NMake Makefiles JOM" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DFFTW_INCLUDES="%LIBRARY_INC%" ^
    -DFFTW_LIBRARY="%LIBRARY_LIB%\fftw3f.lib" ^
    -DBUILD_TESTING=OFF ^
    || goto :error

:: Re-add above when CUDA is available
::    -DCUDA_TOOLKIT_ROOT_DIR="%LIBRARY_BIN%" ^
:: OpenCL should be found automatically?
::    -DOPENCL_INCLUDE_DIR="%LIBRARY_INC%" ^
::    -DOPENCL_LIBRARY="%LIBRARY_LIB%\OpenCL.lib" ^

jom install || goto :error
jom PythonInstall || goto :error
jom install || goto :error

:: Workaround overlinking warnings
copy %SP_DIR%\simtk\openmm\_openmm* %LIBRARY_BIN% || goto :error
copy %LIBRARY_LIB%\OpenMM* %LIBRARY_BIN% || goto :error
copy %LIBRARY_LIB%\plugins\OpenMM* %LIBRARY_BIN% || goto :error

:: Better location for examples
mkdir %LIBRARY_PREFIX%\share\openmm || goto :error
move %LIBRARY_PREFIX%\examples %LIBRARY_PREFIX%\share\openmm || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%