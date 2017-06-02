@echo off

setlocal
cd %~dp0

set GYP_ARGS=
IF "%PROCESSOR_ARCHITECTURE%"=="x86" (set MSVC_PLATFORM=Win32) else (set MSVC_PLATFORM=x64)

REM -------------------------------------------------------------------------
REM -- Check out GYP.  GYP doesn't seem to have releases, so just use the
REM -- current master commit.


if not exist build-gyp (
    git clone https://chromium.googlesource.com/external/gyp build-gyp || (
        echo error: GYP clone failed
        exit /b 1
    )
)
 
REM -------------------------------------------------------------------------
REM -- Run gyp to generate MSVC project files.
    
cd src

call ..\build-gyp\gyp.bat winpty.gyp -I configurations.gypi %GYP_ARGS%
if errorlevel 1 (
    echo error: GYP failed
    exit /b 1
)

REM -------------------------------------------------------------------------
REM -- Compile the project.

msbuild winpty.sln /m /p:Platform=%MSVC_PLATFORM% || (
    echo error: msbuild failed
    exit /b 1
)

copy include\winpty.h %LIBRARY_INC% 
copy include\winpty_constants.h %LIBRARY_INC%

copy Release\%MSVC_PLATFORM%\winpty.dll %LIBRARY_BIN%
copy Release\%MSVC_PLATFORM%\winpty-agent.exe %LIBRARY_BIN%
copy Release\%MSVC_PLATFORM%\winpty-debugserver.exe %LIBRARY_BIN%