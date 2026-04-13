@echo on

cd /d python || exit /b 1

if exist src\cpp rmdir /s /q src\cpp
xcopy /E /I /Y ..\cpp src\cpp >nul || exit /b 1

sed -i.bak "s/version = \"2.0.10\"/version = \"2.1.1\"/" pyproject.toml || exit /b 1
sed -i.bak "s/m.attr(\"version\") = nb::make_tuple(2, 1, 0);/m.attr(\"version\") = nb::make_tuple(2, 1, 1);/" src\bindings.cpp || exit /b 1
del /f /q pyproject.toml.bak src\bindings.cpp.bak 2>nul

set "CMAKE_GENERATOR=Ninja"
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation || exit /b 1
