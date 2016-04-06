@echo off

mkdir build
cd build

set PYLIB=python27.lib

cmake .. -G "NMake Makefiles" ^
    -Wno-dev ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_RPATH:STRING=%LIBRARY_LIB% ^
    -DCMAKE_INSTALL_NAME_DIR=%LIBRARY_LIB% ^
    -DBUILD_DOCUMENTATION=OFF ^
    -DVTK_HAS_FEENABLEEXCEPT=OFF ^
    -DBUILD_TESTING=OFF ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_SHARED_LIBS=ON ^
    -DVTK_WRAP_PYTHON=ON ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    -DPYTHON_INCLUDE_PATH=%PREFIX%\\include ^
    -DPYTHON_LIBRARY=%PREFIX%\\libs\\%PYLIB% ^
    -DVTK_INSTALL_PYTHON_MODULE_DIR=%PREFIX%\\Lib\\site-packages ^
    -DModule_vtkRenderingMatplotlib=ON

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
