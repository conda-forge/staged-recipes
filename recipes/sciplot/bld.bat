mkdir build
cd build

REM Configure step
cmake .. ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
    -DCMAKE_EXE_LINKER_FLAGS="/FORCE:MULTIPLE"  REM This is needed to to bug in MSVC 14.1 in dealing with inline definitions of static data members (Plot::m_counter and Figure::m_counter)
if errorlevel 1 exit 1

REM Build step
ninja install
if errorlevel 1 exit 1
