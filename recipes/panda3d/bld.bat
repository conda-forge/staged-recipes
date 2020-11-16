if %PROCESSOR_ARCHITECTURE% == AMD64 (
  set SUFFIX=-x64
) else (
  set SUFFIX=
)

set thirdparty=thirdparty
set pythondir=win-python%PY_VER%%SUFFIX%

set ADDITIONAL_OPTIONS=

:: Add path for wanted dependencies
FOR %%l in (^
    assimp ^
    bullet ^
    ffmpeg ^
    freetype ^
    jpeg ^
    openal ^
    openssl ^
    openexr ^
    png ^
    python ^
    tiff ^
    vorbis ^
    zlib) DO (
    set ADDITIONAL_OPTIONS= --%%l-incdir %PREFIX%\include %ADDITIONAL_OPTIONS%
    set ADDITIONAL_OPTIONS= --%%l-libdir %PREFIX%\lib %ADDITIONAL_OPTIONS%
)

:: Special treatment for eigen
set ADDITIONAL_OPTIONS= --eigen-incdir %PREFIX%\include\eigen3 %ADDITIONAL_OPTIONS%

:: Disable certain options
FOR %%l in (^
    egl ^
    gles ^
    gles2) DO (
    set ADDITIONAL_OPTIONS=--no-%%l %ADDITIONAL_OPTIONS%
)

:: Make panda using special panda3d tool
%PYTHON makepanda/makepanda.py ^
    --threads=2 ^
    --outputdir=build ^
    --wheel ^
    --everything ^
    --msvc-version=14.1 ^
    --windows-sdk=10 ^
    %ADDITIONAL_OPTIONS
if errorlevel 1 exit 1

:: Install wheel which install python, bin
%PYTHON% -m pip install panda3d*.whl -vv
if errorlevel 1 exit 1
