@echo on
msbuild src/muscle.sln /p:Configuration=Release /p:Platform=x64

if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN%
copy x64\Release\muscle.exe %LIBRARY_BIN%\
