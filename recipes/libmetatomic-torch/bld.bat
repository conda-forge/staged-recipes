cmake -G Ninja %CMAKE_ARGS% -DBUILD_SHARED_LIBS=ON . || goto :error
cmake --build . --config Release --target install || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
