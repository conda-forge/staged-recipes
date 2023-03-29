mkdir -p build
cd build
# in case there are any old psql builds: remove them
rm -rf Code/PgSQL

cmake \
    -D RDK_BUILD_PGSQL=ON \
    -D RDK_PGSQL_STATIC=ON \
    -D CMAKE_INSTALL_PREFIX="$PREFIX" \
    -D BOOST_ROOT="$PREFIX" \
    -D Boost_NO_SYSTEM_PATHS=ON \
    -D Boost_NO_BOOST_CMAKE=ON \
    -D RDK_USE_BOOST_SERIALIZATION=OFF \
    -D RDK_BUILD_CPP_TESTS=OFF \
    -D RDK_BUILD_PYTHON_WRAPPERS=OFF \
    -D RDK_BUILD_INCHI_SUPPORT=ON \
    -D RDK_BUILD_AVALON_SUPPORT=ON \
    -D RDK_BUILD_FREESASA_SUPPORT=OFF \
    -D RDK_BUILD_THREADSAFE_SSS=ON \
    -D RDK_INSTALL_INTREE=OFF \
    -D RDK_INSTALL_STATIC_LIBS=OFF \
    -D RDK_INSTALL_DEV_COMPONENT=OFF \
    -D RDK_INSTALL_STATIC_LIBS=OFF \
    -D RDK_USE_FLEXBISON=OFF \
    -D RDK_TEST_MULTITHREADED=ON \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_FLAGS="-DBOOST_NO_CXX98_FUNCTION_BASE=1"
    ..

make -j$CPU_COUNT

cd ./Code/PgSQL/rdkit

/bin/bash -e ./pgsql_install.sh

export PGPORT=54321
export PGDATA=$SRC_DIR/pgdata

rm -rf $PGDATA # cleanup required when building variants
pg_ctl initdb

# ensure that the rdkit extension is loaded at process startup
echo "shared_preload_libraries = 'rdkit'" >> $PGDATA/postgresql.conf

pg_ctl start -l $PGDATA/log.txt

# wait a few seconds just to make sure that the server has started
sleep 2

set +e
ctest
check_result=$?
set -e

pg_ctl stop

exit $check_result