@echo off
setlocal enabledelayedexpansion

REM conda-build invokes bld.bat a second time during the packaging phase in a
REM fresh cmd session, so VSCMD_VER (set only by a successful vcvarsall call)
REM cannot serve as a cross-session sentinel. Use a file flag to detect that
REM the first build and install already completed successfully and exit early.
set "BUILD_DONE_SENTINEL=%SRC_DIR%\build-conda\.spring2_build_done"
if exist "%BUILD_DONE_SENTINEL%" (
  echo bld.bat: spring2 already built and installed ^(sentinel exists^). Skipping.
  exit /b 0
)

REM Locate VS via vswhere (conda installs it as a build requirement so it is
REM already on PATH) and call vcvarsall.bat. This fixes two problems:
REM  1. CMake "could not find any instance of Visual Studio" - vcvarsall sets
REM  VS170COMNTOOLS and related env vars that cmake uses as hints.
REM  2. ninja 0xC0000139 crash - vcvarsall prepends the VS runtime dirs to
REM  PATH before conda's Library\bin, so the correct vcruntime140.dll is
REM  loaded first.

set "VSWHERE="
if exist "%BUILD_PREFIX%\Library\bin\vswhere.exe" (
  set "VSWHERE=%BUILD_PREFIX%\Library\bin\vswhere.exe"
)
if not defined VSWHERE (
  if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
    set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
  )
)
if not defined VSWHERE (
  echo ERROR: vswhere.exe not found in conda prefix or system installer path
  exit /b 1
)
echo bld.bat: using vswhere at %VSWHERE%

set "VS_PATH="
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2^>nul`) do (
  set "VS_PATH=%%i"
)
if not defined VS_PATH (
  echo ERROR: No VS installation with VC.Tools.x86.x64 found via vswhere
  exit /b 1
)
echo bld.bat: VS installation at %VS_PATH%

REM Only call vcvarsall.bat if the VS environment is not already initialized.
REM conda-build calls bld.bat a second time during packaging. VS 2026 (18.x)
REM vcvarsall.bat returns non-zero when invoked in an already-initialized
REM prompt (unlike VS 17 which was silent), so we skip re-initialization.
REM
REM We check VSCMD_VER rather than VSINSTALLDIR because conda-build explicitly
REM sets VSINSTALLDIR= (empty string) before invoking bld.bat, so
REM "if not defined VSINSTALLDIR" evaluates as already-defined and we would
REM skip initialization even when the VS environment was never actually set up.
REM VSCMD_VER is only set by a successful vcvarsall.bat / VsDevCmd.bat call
REM and is never pre-set by conda-build, making it a reliable sentinel.
if not defined VSCMD_VER (
  REM VS 2026's VsDevCmd.bat errors if INCLUDE, LIB, or LIBPATH are already
  REM set when vcvarsall.bat is called. conda-build's compiler metapackage
  REM activation scripts pre-populate these with conda's Library paths before
  REM bld.bat runs, which triggers the validation failure. Clear them here;
  REM CMake locates conda headers and libs via CMAKE_PREFIX_PATH, not these
  REM env vars, so clearing them does not affect the build.
  set "INCLUDE="
  set "LIB="
  set "LIBPATH="
  call "%VS_PATH%\VC\Auxiliary\Build\vcvarsall.bat" amd64
  if errorlevel 1 (
    echo ERROR: vcvarsall.bat failed
    exit /b 1
  )
  ) else (
  echo bld.bat: VS environment already initialized ^(VSCMD_VER=%VSCMD_VER%^), skipping vcvarsall.bat
)

REM Prefer the vendored ninja shipped in the source tree. After vcvarsall.bat
REM has run, VS runtime dirs are prepended to PATH, so any ninja on PATH will
REM load the correct CRT even if conda's Library\bin copy is also present.
set "SPRING_NINJA=%SRC_DIR%\tools\host\ninja\win\ninja.exe"
if not exist "%SPRING_NINJA%" set "SPRING_NINJA=%BUILD_PREFIX%\Library\bin\ninja.exe"
if not exist "%SPRING_NINJA%" (
  for /f "usebackq tokens=*" %%i in (`where ninja 2^>nul`) do (
    set "SPRING_NINJA=%%i"
    goto :ninja_found
  )
  echo ERROR: ninja not found in vendored path, conda prefix, or PATH
  exit /b 1
)
:ninja_found
echo bld.bat: using ninja at %SPRING_NINJA%

REM CMAKE_POLICY_DEFAULT_CMP0091=NEW and CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
REM ensure the static CRT is used project-wide, including in vendor subdirectories.
cmake -S . -B build-conda -G Ninja ^
-DCMAKE_MAKE_PROGRAM="%SPRING_NINJA%" ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
-DCMAKE_INSTALL_BINDIR=Library\bin ^
-DCMAKE_INSTALL_LIBDIR=Library\lib ^
-DSPRING_ENABLE_COMPILER_CACHE=OFF ^
-DCMAKE_POLICY_DEFAULT_CMP0091=NEW ^
-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
if errorlevel 1 exit /b 1

cmake --build build-conda --parallel
if errorlevel 1 exit /b 1

cmake --install build-conda
if errorlevel 1 exit /b 1

echo done > "%BUILD_DONE_SENTINEL%"
