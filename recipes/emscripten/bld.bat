
SET "BINARYEN=%PREFIX%"

python tools\install.py %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\
IF ERRORLEVEL 1 EXIT 1

RMDIR /s /q %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\tests\
IF ERRORLEVEL 1 EXIT 1

@rem remove leftovers
DEL %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\build_env_setup.bat
DEL %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\conda_build.bat
IF ERRORLEVEL 1 EXIT 1

python %RECIPE_DIR%\link_bin.py
IF ERRORLEVEL 1 EXIT 1

CD %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\
CALL emcc.bat
IF ERRORLEVEL 1 EXIT 1

python %RECIPE_DIR%\fix_emscripten_config.py
IF ERRORLEVEL 1 EXIT 1

CD %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\
npm install
IF ERRORLEVEL 1 EXIT 1

