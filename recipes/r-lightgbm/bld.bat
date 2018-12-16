:: derived from https://github.com/Microsoft/LightGBM/blob/master/build_r.R

:: go one level up
cd "%SRC_DIR%"
cd ..

:: Definition and creation of the build folder
set "BUILD_DIR=%CD%\build_dir"
mkdir "%BUILD_DIR%" || goto :error

:: Bring everything in place
xcopy /E "%SRC_DIR%\R-package" "%BUILD_DIR%"               || goto :error
xcopy /E /I "%SRC_DIR%\include" "%BUILD_DIR%\src\include"  || goto :error
xcopy /E /I "%SRC_DIR%\src" "%BUILD_DIR%\src\src"          || goto :error
copy /B "%SRC_DIR%\CMakeLists.txt" "%BUILD_DIR%\inst\bin\" || goto :error

:: Build it
cd "%BUILD_DIR%"
"%R%" CMD INSTALL --build . || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
