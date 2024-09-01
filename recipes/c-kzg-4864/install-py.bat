@echo off

%PYTHON% -m pip install %SRC_DIR%\wheels\%PKG_NAME%-%PKG_VERSION%-*.whl ^
--no-build-isolation ^
--no-deps ^
--only-binary :all: ^
--prefix "%PREFIX%"
if errorlevel 1 exit 1
