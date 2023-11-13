mkdir build
pushd build

cmake %CMAKE_ARGS% -GNinja -DSIMDUTF_TOOLS=OFF -DBUILD_SHARED_LIBS=ON ..
if %ERRORLEVEL% neq 0 exit 1

ninja install
if %ERRORLEVEL% neq 0 exit 1

popd
