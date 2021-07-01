@REM Configure the build of Optima
cmake -S . -B build ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_INCLUDE_PATH=%LIBRARY_INC% ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -DPYTHON_EXECUTABLE=%PYTHON%

@REM Build and install Optima in %LIBRARY_PREFIX%
@REM Note: No need for --parallel below, since cmake takes care of the /MP flag for MSVC
cmake --build build --config Release --target install

@REM In Windows, conda-forge Python packages must be located in %PREFIX%\site-packages.
@REM The above install command places them in %PREFIX%\Library\site-packages instead.
cmake -E copy_directory %LIBRARY_PREFIX%\site-packages %PREFIX%\site-packages
cmake -E remove_directory %LIBRARY_PREFIX%\site-packages
