@echo ON
setlocal enabledelayedexpansion

mkdir build-py%PY_VER%
pushd build-py%PY_VER%

if "%PY3K%" == "0" (
    echo "Copying stdint.h for windows"
    copy "%LIBRARY_INC%\stdint.h" %SRC_DIR%\modules\calib3d\include\stdint.h
    copy "%LIBRARY_INC%\stdint.h" %SRC_DIR%\modules\videoio\include\stdint.h
    copy "%LIBRARY_INC%\stdint.h" %SRC_DIR%\modules\highgui\include\stdint.h
)

for /F "tokens=1,2 delims=. " %%a in ("%PY_VER%") do (
   set "PY_MAJOR=%%a"
   set "PY_MINOR=%%b"
)
set PY_LIB=python%PY_MAJOR%%PY_MINOR%.lib


:: CMake/OpenCV like Unix-style paths for some reason.
set UNIX_PREFIX=%PREFIX:\=/%
set UNIX_LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%
set UNIX_LIBRARY_BIN=%LIBRARY_BIN:\=/%
set UNIX_SP_DIR=%SP_DIR:\=/%
set UNIX_SRC_DIR=%SRC_DIR:\=/%

cmake .. -LAH -G "%CMAKE_GENERATOR%"                                        ^
    -DCMAKE_BUILD_TYPE="Release"                                            ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX%                                         ^
    -DCMAKE_INSTALL_LIBDIR=lib                                              ^
    -DCMAKE_STATIC_LIBRARY_SUFFIX_CXX=-static.lib                           ^
    -DCMAKE_STATIC_LIBRARY_SUFFIX_C=-static.lib                             ^
    -DCMAKE_SKIP_RPATH=ON                                                   ^
    -DLIEF_SHARED_LIB=ON                                                    ^
    -DLIEF_PYTHON_API=ON                                                    ^
    -DLIEF_INSTALL_PYTHON=ON                                                ^
    -DPYTHON_VERSION=%PY_VER%                                               ^
    -DPYTHON_LIBRARY=%PREFIX%\libs\python%CONDA_PY%.lib                     ^
    -DPYTHON_LIBRARY_DEBUG=%PREFIX%\libs\python%CONDA_PY%.lib               ^
    -DPYTHON_INCLUDE_DIR:PATH=%PREFIX%\include                              ^
    -DPYTHON_EXECUTABLE=%PREFIX%\python.exe

:: cmake --build . --config Release --target CLEAN -- VERBOSE=1  -- -j%CPU_COUNT%
:: cmake --build . --config Release --target INSTALL -- VERBOSE=1

cmake --build . -j %CPU_COUNT% --config Release --target install -- -verbosity:normal
if errorlevel 1 exit /b 1

pushd api\python
  if not exist %SP_DIR%\lief mkdir %SP_DIR%\lief
  pushd lief
    copy __init__.py %SP_DIR%\lief\
    copy _pylief.pyd %SP_DIR%\
  pod
  %PYTHON% -c "import lief"
  if errorlevel neq 0 exit /b 1
popd

:: Unfortunate examples.
del /s /q %PREFIX%\share\LIEF
