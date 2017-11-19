@echo on

if "%ARCH%" == "32" (
  set ARCH=Win32
) else (
  set ARCH=x64
)

:: See https://github.com/conda-forge/staged-recipes/pull/194#issuecomment-203577297
:: Nasty workaround. Need to move a more current msbuild into PATH.  The one on
:: AppVeyor barfs on the solution. This one comes from the Win7 SDK (.net 4.0),
:: and is known to work.
if %VS_MAJOR% == 9 (
    COPY C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe .\
    set "PATH=%CD%;%PATH%"
)

if "%VS_YEAR%" == "2008" (
  xcopy /s /y /i %RECIPE_DIR%\vs2008 %SRC_DIR%\builds\msvc\vs%VS_YEAR%
  copy %LIBRARY_INC%\stdint.h %SRC_DIR%\builds\msvc\
  copy %LIBRARY_INC%\inttypes.h %SRC_DIR%\builds\msvc\
  cd /d %SRC_DIR%\builds\msvc\vs%VS_YEAR%\dynamic
  msbuild libsodium.sln /p:Configuration=Release /p:Platform=%ARCH%
  if errorlevel 1 exit 1
  cd /d %SRC_DIR%\builds\msvc\vs%VS_YEAR%\static
  msbuild libsodium.sln /p:Configuration=Release /p:Platform=%ARCH%
  if errorlevel 1 exit 1
  :: Generate version.h
  cd /d %SRC_DIR%
  call msvc-scripts\process.bat
  if errorlevel 1 exit 1
  set ARTIFACTS_DIR=%SRC_DIR%\bin\%ARCH%\Release\v90\
) else (
  cd /d %SRC_DIR%\builds\msvc\vs%VS_YEAR%\
  msbuild libsodium.sln /p:Configuration=DynRelease /p:Platform=%ARCH%
  if errorlevel 1 exit 1
  msbuild libsodium.sln /p:Configuration=StaticRelease /p:Platform=%ARCH%
  if errorlevel 1 exit 1
  set ARTIFACTS_DIR=%SRC_DIR%\bin\%ARCH%\Release\v140\
)

if "%VS_YEAR%" == "2010" (
  set ARTIFACTS_DIR=%SRC_DIR%\bin\%ARCH%\Release\v100\
)

move %ARTIFACTS_DIR%\dynamic\libsodium.dll %LIBRARY_BIN%
move %ARTIFACTS_DIR%\dynamic\libsodium.lib %LIBRARY_LIB%
move %ARTIFACTS_DIR%\static\libsodium.lib %LIBRARY_LIB%\libsodium_static.lib
xcopy /s /y /i %SRC_DIR%\src\libsodium\include\sodium %LIBRARY_INC%\sodium
xcopy /s /y %SRC_DIR%\src\libsodium\include\sodium.h %LIBRARY_INC%\
