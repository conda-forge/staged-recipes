SETLOCAL EnableDelayedExpansion

pushd "%SRC_DIR%" || exit /b !ERRORLEVEL!

%PYTHON% setup.py build_ext --incdir=%LIBRARY_INC% --ittlib=%LIBRARY_LIB%\libittnotify.lib || exit /b !ERRORLEVEL!
%PYTHON% setup.py install || exit /b !ERRORLEVEL!

popd
