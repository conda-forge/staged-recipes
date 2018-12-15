
# build links to system zlib sometimes
# here we do an explicit fix...
if [[ `otool -L ${PREFIX}/lib/libgfortran.${PKG_VERSION:0:1}.dylib  | grep "/usr/lib/libz"` ]]
then
    echo "did the thing"
    install_name_tool -change /usr/lib/libz.1.dylib @rpath/libz.1.dylib ${PREFIX}/lib/libgfortran.${PKG_VERSION:0:1}.dylib
fi
