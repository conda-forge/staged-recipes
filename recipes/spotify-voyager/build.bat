@echo on
@setlocal EnableDelayedExpansion

:: prepare sources
cd /d "%SRC_DIR%\python" || goto :error

if exist "src\cpp" rd "src\cpp"
if exist "src\cpp" rmdir /s /q "src\cpp"
if exist "src\cpp" goto :error

xcopy /E /I /Y "%SRC_DIR%\cpp" "src\cpp\" >nul || goto :error

:: patch broken v2.1.1 release metadata to match the tagged release
sed -i.bak "s/version = \"2.0.10\"/version = \"2.1.1\"/" "pyproject.toml" || goto :error

sed -i.bak "s/m.attr(\"version\") = nb::make_tuple(2, 1, 0);/m.attr(\"version\") = nb::make_tuple(2, 1, 1);/" "src\bindings.cpp" || goto :error

del /f /q "pyproject.toml.bak" "src\bindings.cpp.bak" 2>nul

:: build
set "CMAKE_GENERATOR=Ninja"
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation || goto :error

echo build.bat: OK
goto :eof

:error
echo Failed with error #%errorlevel%.
exit /b 1
