mkdir build
cd build

cmake.exe .. -G "NMake Makefiles JOM" -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_BUILD_TYPE=Release -DOPENMM_GENERATE_API_DOCS=ON ^
    -DFFTW_INCLUDES="%LIBRARY_INC%" -DFFTW_LIBRARY="%LIBRARY_LIB%/fftw3f.lib" ^
    || goto :error
jom install || goto :error
jom PythonInstall || goto :error
jom install || goto :error


mkdir %PREFIX%\share\openmm || goto :error
move %PREFIX%\examples %PREFIX%\share\openmm || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%