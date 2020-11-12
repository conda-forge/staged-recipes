
set "BINARYEN=%PREFIX%"

python tools\install.py %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\

@rem remove leftovers
rm %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\build_env_setup.bat
rm %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\conda_build.bat

python %RECIPE_DIR%\link_bin.py

cd %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\
emcc.bat

python %RECIPE_DIR%\fix_emscripten_config.py

cd %LIBRARY_PREFIX%\lib\emscripten-%PKG_VERSION%\
npm install