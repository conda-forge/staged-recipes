@echo on
md %LIBRARY_PREFIX%/bin
if errorlevel 1 exit 1
7z x 20348.1.210507-1500.fe_release_WindowsSDK.iso -aoa
if errorlevel 1 exit 1
7z x -o -C tmp "Installers/Universal CRT Redistributable-x86_en-us.msi"
if errorlevel 1 exit 1
xcopy "tmp\Program Files\Windows Kits\10\Redist\%PKG_VERSION%\ucrt\DLLs\x64\"* "%PREFIX%"
if errorlevel 1 exit 1
xcopy "tmp\Program Files\Windows Kits\10/Redist\%PKG_VERSION%\ucrt\DLLs\x64\"* "%LIBRARY_PREFIX%\bin"
if errorlevel 1 exit 1
