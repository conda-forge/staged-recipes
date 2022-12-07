@echo on

mkdir build
pushd build

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"

cmake -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DBUILD_SHARED_LIBS=ON ^
    ..

if %ERRORLEVEL% neq 0 exit 1

cmake --build . --verbose --config Release -- -v -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install . --verbose --config Release
if %ERRORLEVEL% neq 0 exit 1

popd

initdb -D test_db
pg_ctl -D test_db -l test.log -o "-F -p 5434" start
createuser --username=%USERNAME% -w --port=5434 -s postgres
pg_regress --port=5434 --inputdir=test --bindir=%LIBRARY_PREFIX%\bin btree cast copy functions input ivfflat_cosine ivfflat_ip ivfflat_l2 ivfflat_options ivfflat_unlogged
pg_ctl -D test_db stop