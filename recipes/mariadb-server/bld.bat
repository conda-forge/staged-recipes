:: Build with CMake
cmake -S . -B build -G Ninja ^
    -DMYSQL_DATADIR="%LIBRARY_PREFIX%\var\mysql" ^
    -DINSTALL_INCLUDEDIR="include\mysql" ^
    -DINSTALL_MANDIR="share\man" ^
    -DINSTALL_DOCDIR="share\doc\mariadb" ^
    -DINSTALL_INFODIR="share\info" ^
    -DINSTALL_MYSQLSHAREDIR="share\mysql" ^
    -DWITH_LIBFMT=system ^
    -DWITH_SSL=system ^
    -DWITH_UNIT_TESTS=OFF ^
    -DDEFAULT_CHARSET=utf8mb4 ^
    -DDEFAULT_COLLATION=utf8mb4_general_ci ^
    -DINSTALL_SYSCONFDIR="%LIBRARY_PREFIX%\etc" ^
    -DALL_ON_WINDOWS="" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -Wno-dev ^
    -DBUILD_TESTING=OFF ^
    %CMAKE_ARGS% || goto :error

cmake --build build -- -j%CPU_COUNT% || goto :error
cmake --install build || goto :error

:: Delete some large folders to reduce package size
del /F /Q /S "%LIBRARY_PREFIX%\mariadb-test"
del /F /Q /S "%LIBRARY_PREFIX%\sql-bench"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
