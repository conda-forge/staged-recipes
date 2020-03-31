:: MSVC is preferred.
set CC=cl.exe
set CXX=cl.exe

mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
    -Duse_installed_dependencies=ON ^
    -Dskip_samples=ON ^
    -Duse_default_uuid=ON ^
    -Dbuild_as_dynamic=ON ^
    -Duse_edge_modules=ON ^
    -Duse_prov_client=OFF ^
    -Dhsm_type_symm_key=OFF ^
    -Duse_etw=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
