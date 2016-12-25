setlocal EnableDelayedExpansion

copy %RECIPE_DIR%\CMakeLists.txt .\CMakeLists.txt

:: Make a build folder and change to it.
mkdir build
cd build

:: Configure using the CMakeFiles
%LIBRARY_BIN%\cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE:STRING=Release .. 
if errorlevel 1 exit 1

:: Build!
nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

:: Go back to source dir
cd ..

:: Copy headers of dependency dlls that are supplied with the source. It is impossible to compile them
:: with the anaconda build environment, but I doubt it will be a problem to just use the included dlls
:: as these libraries will probably only ever be used together with sdl2_mixer, and only if one tries
:: to play music from the ancient MOD format (which I think will be very rarely)
xcopy %SRC_DIR%\VisualC\external\include\libmodplug %LIBRARY_PREFIX%\include\libmodplug /I

:: Copy the dll's of these dependencies
if %ARCH%==32 (
	set FOLDER=x86
) else if %ARCH%==64 (
	set FOLDER=x64
)

copy "%SRC_DIR%\VisualC\external\lib\%FOLDER%\libmodplug-1.dll" "%LIBRARY_PREFIX%\bin\libmodplug-1.dll"
