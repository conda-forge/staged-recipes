setlocal EnableDelayedExpansion

copy "%RECIPE_DIR%\0001-Python-3-support.patch" "0001-Python-3-support.patch"

git apply  --whitespace=fix --ignore-whitespace --reject 0001-Python-3-support.patch


:: Make a build folder and change to it.
mkdir build
cd build


:: Configure using the CMakeFiles
cmake -G "NMake Makefiles JOM" ^
      -DBTK_WRAP_PYTHON:BOOL=1 ^
      -DCMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DPYTHON_LIBRARY="%PREFIX%\libs\python%CONDA_PY%.lib" ^
      -DPYTHON_INCLUDE_DIR="%PREFIX%\include" ^
      -DCMAKE_PREFIX_PATH:PATH="%PREFIX%" ^
      -DBUILD_DOCUMENTATION:BOOL=0 ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DBUILD_SHARED_LIBS:BOOL=1 ^
      %SRC_DIR%


if errorlevel 1 exit 1

:: Build!
nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

:: Remove cmake files
RMDIR /Q/S "%LIBRARY_PREFIX%\share\btk-0.4dev"

:: Collect bin/_btk.pyd and bin/btk.py move it to site_packages
copy "bin\btk.py" "%SP_DIR%\btk.py"
copy "bin\_btk.pyd" "%SP_DIR%\_btk.pyd"

if errorlevel 1 exit 1
