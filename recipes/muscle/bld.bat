@echo on
cd src || exit 1
echo "0" > gitver.txt

msbuild muscle.sln /p:Configuration=Release

if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN%
copy x64\Release\muscle.exe %LIBRARY_BIN%\
