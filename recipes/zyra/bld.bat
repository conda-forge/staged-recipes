cargo build --release --bin zyra
if errorlevel 1 exit 1
copy target\release\zyra.exe %PREFIX%\Scripts\zyra.exe
if errorlevel 1 exit 1
