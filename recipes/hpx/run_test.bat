pushd test

if [[ "$target_platform" == "osx-64" ]]; then
    # https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake . -D CMAKE_BUILD_TYPE="Release"
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build . --config Release
if %errorlevel% neq 0 exit /b %errorlevel%

Release\hello_hpx.exe
if %errorlevel% neq 0 exit /b %errorlevel%

popd
