cd $SRC_DIR
dotnet tool restore
if [[ "${target_platform}" == "osx-64" ]]; then
    dotnet fake build -t publishBinariesMac
    cp "publish/osx-x64/arc" "${PREFIX}"
    chmod u+x "${PREFIX}/arc"
else
    dotnet publish -c Release -p:UseAppHost=false
    PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
    DOTNET_ROOT="${PREFIX}/lib/dotnet"
    TOOL_ROOT=$DOTNET_ROOT/tools/arccommander

    mkdir -p $PREFIX/bin $TOOL_ROOT
    cp -r $SRC_DIR/src/ArcCommander/bin/Release/net6.0/* $TOOL_ROOT
    cp "$RECIPE_DIR/arc.sh" "$PREFIX/bin/arc"
    chmod +x "$PREFIX/bin/arc"
fi

