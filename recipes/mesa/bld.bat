REM scons is only available for python2, so let's create a separate env for it
call conda create -y -n %SRC_DIR%\_conda_build_scons_env scons mako
if errorlevel 1 exit 1

set LLVM=%PREFIX%\Library
call %SRC_DIR%\_conda_build_scons_env\Scripts\scons -j%CPU_COUNT% ^
                                                    build=release ^
                                                    MSVC_VERSION=14.0 ^
                                                    llvm=yes ^
                                                    libgl-gdi
if errorlevel 1 exit 1

if "%ARCH%" == "32" (
    set ARCH_DIR=windows-x86
) else (
    set ARCH_DIR=windows-x86_64
)

copy "build\%ARCH_DIR%\gallium\targets\libgl-gdi\opengl32.dll" "%PREFIX%\Library\bin\"
if errorlevel 1 exit 1
