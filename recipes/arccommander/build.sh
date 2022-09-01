cd $SRC_DIR
dotnet tool restore
if [[ "${target_platform}" == "osx-64" ]]; then
    dotnet fake build -t publishBinariesMac
    cp "publish/osx-x64/arc" "${PREFIX}"
    chmod u+x "${PREFIX}/arc"
else
    dotnet fake build -t publishBinariesLinux
    cp "publish/linux-x64/arc" "${PREFIX}"
    chmod u+x "${PREFIX}/arc"
fi

