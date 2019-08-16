mkdir build
cd build

cmake.exe .. -G "NMake Makefiles JOM" -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_BUILD_TYPE=Release -DOPENMM_GENERATE_API_DOCS=ON ^
    -DFFTW_INCLUDES="%LIBRARY_INC%" -DFFTW_LIBRARY="%LIBRARY_LIB%/fftw3f.lib" ^
    || goto :error
jom install || goto :error
jom PythonInstall || goto :error
REM jom C++ApiDocs || goto :error
REM jom PythonApiDocs || goto :error
REM jom sphinxpdf || goto :error
jom install || goto :error

REM mkdir openmm-docs || goto :error
REM robocopy %PREFIX%\docs openmm-docs * /e /move || goto :error
REM mkdir %PREFIX%\docs || goto :error
REM move openmm-docs %PREFIX%\docs\openmm || goto :error
mkdir %PREFIX%\share\openmm || goto :error
move %PREFIX%\examples %PREFIX%\share\openmm || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%