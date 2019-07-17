:: Copied from https://github.com/ryanvolz/libusb-feedstock/blob/ac0acf5fab7a4ebdd32b0b5972f88f49bc815bf1/recipe/bld.bat
setlocal EnableDelayedExpansion

:: Configure
if "%ARCH%" == "32" (
  set SLN_PLAT=Win32
) else (
  set SLN_PLAT=x64
)

:: See https://github.com/conda-forge/staged-recipes/pull/194#issuecomment-203577297
:: Nasty workaround. Need to move a more current msbuild into PATH.  The one on
:: AppVeyor barfs on the solution. This one comes from the Win7 SDK (.net 4.0),
:: and is known to work.
if %VS_MAJOR% == 9 (
    COPY C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe .\
    set "PATH=%CD%;%PATH%"
    :: workaround for msbuild 4.0 bug for VC 2008 projects targeting x64
    set VC_PROJECT_ENGINE_NOT_USING_REGISTRY_FOR_INIT=1
)

if "%VS_YEAR%" == "2008" (
  call vcbuild /upgrade msvc\libusb_dll_2005.vcproj
  if errorlevel 1 exit 1
  call vcbuild /upgrade msvc\libusb_static_2005.vcproj
  if errorlevel 1 exit 1
  call vcbuild /upgrade msvc\listdevs_2005.vcproj
  if errorlevel 1 exit 1
  call vcbuild /upgrade msvc\stress_2005.vcproj
  if errorlevel 1 exit 1
  call vcbuild /upgrade msvc\xusb_2005.vcproj
  if errorlevel 1 exit 1
  set SLN_FILE="msvc\libusb_2005.sln"
  set TOOLSVERSION=3.5
)
if "%VS_YEAR%" == "2010" (
  set SLN_FILE="msvc\libusb_2010.sln"
  set TOOLSVERSION=4.0
)
if "%VS_YEAR%" == "2015" (
  set SLN_FILE="msvc\libusb_2015.sln"
  set TOOLSVERSION=14.0
)

:: Build
msbuild "%SLN_FILE%" ^
  /p:Configuration="Release" ^
  /p:Platform="%SLN_PLAT%" ^
  /toolsversion:"%TOOLSVERSION%" ^
  /verbosity:normal
if errorlevel 1 exit 1

:: Install
copy %SRC_DIR%\%SLN_PLAT%\Release\dll\libusb-1.0.dll %LIBRARY_BIN%\
if errorlevel 1 exit 1
copy %SRC_DIR%\%SLN_PLAT%\Release\dll\libusb-1.0.lib %LIBRARY_LIB%\
if errorlevel 1 exit 1
copy %SRC_DIR%\%SLN_PLAT%\Release\dll\libusb-1.0.pdb %LIBRARY_LIB%\
if errorlevel 1 exit 1
copy %SRC_DIR%\%SLN_PLAT%\Release\lib\libusb-1.0.lib %LIBRARY_LIB%\libusb-1.0_static.lib
if errorlevel 1 exit 1
mkdir %LIBRARY_INC%\libusb-1.0
copy %SRC_DIR%\libusb\libusb.h %LIBRARY_INC%\libusb-1.0\
if errorlevel 1 exit 1