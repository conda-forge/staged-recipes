:: get the env
set | sort

:: TODO: remove mingw from path

:: Setup MSYS2 (https://www.msys2.org/docs/ci/)
cmd /C msys2.cmd "pacman --noconfirm -Syuu"

:: Build mingw-gcc inside MSYS2 env
cmd /C msys2.cmd "chmod +x build-mingw-gcc.sh; ./build-mingw-gcc.sh %PKG_VERSION%"

:: Kill MSYS2 hanging process
taskkill /F /FI "MODULES eq msys-2.0.dll"
taskkill /F /FI "MODULES eq libpython2.7.dll"

:: Collect build artifacts
if not exist %LIBRARY_PREFIX% mkdir %LIBRARY_PREFIX% || exit 1
xcopy /I /E /Q C:\mingw-build\x86_64-840-posix-seh-rt_v7-rev0\mingw64 %LIBRARY_PREFIX% || exit 1
