@echo on

cd /d "%SRC_DIR%\python"
if errorlevel 1 exit /b 1

if exist src\cpp rmdir /s /q src\cpp
if errorlevel 1 exit /b 1
xcopy /E /I /Y "%SRC_DIR%\cpp" src\cpp >nul
if errorlevel 1 exit /b 1

sed -i.bak "s/version = \"2.0.10\"/version = \"2.1.1\"/" pyproject.toml
if errorlevel 1 exit /b 1
sed -i.bak "s/m.attr(\"version\") = nb::make_tuple(2, 1, 0);/m.attr(\"version\") = nb::make_tuple(2, 1, 1);/" src\bindings.cpp
if errorlevel 1 exit /b 1
del /f /q pyproject.toml.bak src\bindings.cpp.bak 2>nul

set "CMAKE_GENERATOR=Ninja"
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
