cd vowpalwabbit

.nuget\nuget.exe restore vw.sln

msbuild vw.sln /m /verbosity:normal /p:Configuration=Release;Platform=x64

dir "%SRC_DIR%\vowpalwabbit\x64\Release"

xcopy "%SRC_DIR%\vowpalwabbit\x64\Release" "%LIBRARY_BIN%" /mir
