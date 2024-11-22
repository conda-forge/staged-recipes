@echo on
setlocal EnableDelayedExpansion

cmake -B "build" -G "Ninja" ^
 !CMAKE_ARGS! ^
 -D CMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
 -D USE_CONDA_PYBIND11:BOOL=ON ^
 -D PYTHON_INCLUDE_DIR=%PREFIX%\include ^
 -D PYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
 .

if errorlevel 1 exit 1

cmake --build "build"

if errorlevel 1 exit 1

cmake --install "build"

if errorlevel 1 exit 1

REM move the output files to the appropriate directories
move /Y %LIBRARY_LIB%\TopologicCore\*.dll %LIBRARY_PREFIX%\bin
move /Y %LIBRARY_LIB%\TopologicCore\*.lib %LIBRARY_PREFIX%\lib
move /Y %LIBRARY_LIB%\TopologicPythonBindings\*.pyd %PREFIX%\DLLs
