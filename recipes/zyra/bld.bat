if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
rustc core\bin\zyra.rs -o "%PREFIX%\Scripts\zyra.exe"
if errorlevel 1 exit 1
copy "%PREFIX%\Scripts\zyra.exe" "%PREFIX%\bin\zyra.exe"
if errorlevel 1 exit 1
