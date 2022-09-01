cd $SRC_DIR
dotnet tool restore
if [[ "${target_platform}" == "osx-64" ]]; then
    dotnet fake build -t publishBinariesMac
    copy publish\osx-x64\arc %PREFIX%
else
    dotnet fake build -t publishBinariesLinux
    cp publish\linux-x64\arc %PREFIX%
fi

