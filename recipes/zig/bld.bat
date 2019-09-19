mkdir build
cd build
cmake .. -Thost=x64 -G "Visual Studio 16 2019" -A x64 -DCMAKE_BUILD_TYPE=RelWithDebInfo
msbuild -p:Configuration=RelWithDebInfo INSTALL.vcxproj
