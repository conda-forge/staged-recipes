if "%ARCH%" == "32" (set "ARCH_DIR=x86")
if "%ARCH%" == "64" (set "ARCH_DIR=amd64")

dir /a:d /o:-n /s /b C:\Windows\WinSxS\%ARCH_DIR%_microsoft.vc90.openmp* > vcomp90_locs.txt
type vcomp90_locs.txt

set /p VCOMP_DIR=<vcomp90_locs.txt
echo "%VCOMP_DIR%"

for %%F in ("." "bin") do (
    cmake -G "%CMAKE_GENERATOR%" ^
          -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
          -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS:PATH="%VCOMP_DIR%\vcomp90.dll" ^
          -DCMAKE_INSTALL_DEBUG_LIBRARIES:BOOL="OFF" ^
          -DCMAKE_INSTALL_DEBUG_LIBRARIES_ONLY:BOOL="OFF" ^
          -DCMAKE_INSTALL_OPENMP_LIBRARIES:BOOL="ON" ^
          -DCMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION:STRING=%%F ^
          "%RECIPE_DIR%"
    if errorlevel 1 exit 1

    cmake --build "%SRC_DIR%" ^
          --target INSTALL ^
          --config Release
    if errorlevel 1 exit 1
)
