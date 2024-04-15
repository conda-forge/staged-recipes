cargo-bundle-licenses --format yaml  --output THIRDPARTY_LICENSES.yaml || goto :error

cmake -G Ninja %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DRUST_BUILD_TARGET=%CARGO_BUILD_TARGET% ^
    -DMETATENSOR_INSTALL_BOTH_STATIC_SHARED=OFF ^
    .  || goto :error

cmake --build . --config Release --target install || goto :error


goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
