mkdir build
cd build

REM Configure step
cmake .. ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_EXE_LINKER_FLAGS="/FORCE:MULTIPLE"

REM Note: /FORCE:MULTIPLE is needed because of a bug in MSVC 14.1
REM in dealing with inline definitions of static
REM data members (Plot::m_counter and Figure::m_counter)

if errorlevel 1 exit 1

REM Build step
ninja install
if errorlevel 1 exit 1

REM Test step
tests\Release\sciplot-cpptests.exe
if errorlevel 1 exit 1
