cd $SRC_DIR
dotnet tool restore
dotnet fake build -t publishBinariesWin
copy publish\win-x64\arc.exe %PREFIX%