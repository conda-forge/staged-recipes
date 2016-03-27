cd build.vc14

if "%ARCH%"=="32" (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
)

msbuild gc LIB %PLATFORM% Release

mkdir %PREFIX%\mpir\lib\%PLATFORM%\Release

cd ..

copy lib\%PLATFORM%\Release\mpir.lib lib\%PLATFORM%\Release\gmp.lib
copy lib\%PLATFORM%\Release\mpirxx.lib lib\%PLATFORM%\Release\gmpxx.lib

xcopy lib %PREFIX%\mpir\lib\ /E

