@echo on

:: The PyPI tarball has a partial src\octomap directory (headers only).
:: We replace it with the full source we downloaded.
rd /s /q src\octomap
move octomap_repo src\octomap

:: Patch the PS1 script to remove hardcoded x64 architecture to support cross-compilation (win-arm64)
powershell -Command "(Get-Content scripts\ci\build_octomap_windows.ps1) -replace '\"-A\", \"x64\",', '' | Set-Content scripts\ci\build_octomap_windows.ps1"

:: Execute the CI powershell script to build the OctoMap shared libraries
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\ci\build_octomap_windows.ps1 -ProjectRoot .
if errorlevel 1 exit 1

:: The script puts DLLs and LIBs in src\octomap\lib
:: We copy the DLLs to the conda library bin dir so they are in PATH at runtime
copy src\octomap\lib\*.dll "%LIBRARY_BIN%\"
if errorlevel 1 exit 1

:: We copy the LIB files to the conda library lib dir for linking (optional but good practice)
copy src\octomap\lib\*.lib "%LIBRARY_LIB%\"
if errorlevel 1 exit 1

:: Copy the OctoMap license to the root for packaging
:: It is located in a subdirectory (octomap\)
for /r src\octomap %%f in (LICENSE.txt) do if exist "%%f" copy "%%f" LICENSE_OCTOMAP.txt
if errorlevel 1 exit 1

:: Install the python package
"%PYTHON%" -m pip install . -vv
if errorlevel 1 exit 1
