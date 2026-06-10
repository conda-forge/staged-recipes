cmake -G Ninja -S "%SRC_DIR%" -B build ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%\Library" ^
    -DCMAKE_INSTALL_LIBEXECDIR=libexec/cetmodules ^
    -DBUILD_TESTING=OFF
if errorlevel 1 exit 1
cmake --build build --parallel %CPU_COUNT% --target install
if errorlevel 1 exit 1

REM Replace upstream symlinks with regular copies so the noarch package
REM installs cleanly on Windows. cmd's COPY follows symlinks/reparse points,
REM so this works whether tar extraction preserved the symlinks or not.
for %%F in ("%PREFIX%\Library\share\cetmodules\Modules\FindFFTW3?.cmake") do (
    if exist "%%~F" (
        copy /B /Y "%%~F" "%%~F.real" >nul
        if errorlevel 1 exit 1
        move /Y "%%~F.real" "%%~F" >nul
        if errorlevel 1 exit 1
    )
)
