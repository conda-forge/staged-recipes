#!/bin/bash

set -ex

# Update SQLiteCpp version
sed -i.bak 's,mlin/SQLiteCpp.git,SRombauts/SQLiteCpp,g' CMakeLists.txt
sed -i.bak 's,6d089fc,643b153,g' CMakeLists.txt

cmake -DCMAKE_BUILD_TYPE=Release -B build

sed -i.bak '1i #include <climits>' build/_deps/sqlite_web_vfs-src/src/SQLiteVFS.h
sed -i.bak 's,sqlite3_int64 page_count,int64_t page_count,g' src/SQLiteNestedVFS.h

sed -i.bak '258s/btree_interior_pageno_cursor->bind(1, pageno);/btree_interior_pageno_cursor->bind(1, (int64_t)pageno);/' src/SQLiteNestedVFS.h
sed -i.bak '264s/btree_interior_cursor->bind(1, pageno);/btree_interior_cursor->bind(1, (int64_t)pageno);/' src/SQLiteNestedVFS.h
sed -i.bak '279s/cursor.bind(1, pageno);/cursor.bind(1, (int64_t)pageno);/' src/SQLiteNestedVFS.h
sed -i.bak '778s/upsert->bind(2, job->meta1);/upsert->bind(2, (int64_t)job->meta1);/' src/SQLiteNestedVFS.h
sed -i.bak '781s/upsert->bind(3, job->meta2);/upsert->bind(3, (int64_t)job->meta2);/' src/SQLiteNestedVFS.h
sed -i.bak '784s/upsert->bind(4, job->pageno);/upsert->bind(4, (int64_t)job->pageno);/' src/SQLiteNestedVFS.h
sed -i.bak '787s/upsert->bind(5, job->pageno);/upsert->bind(5, (int64_t)job->pageno);/' src/SQLiteNestedVFS.h
sed -i.bak '803s/upsert->bind(btree_interior_index_.empty() ? 4 : 5, (sqlite_int64)-100);/upsert->bind(btree_interior_index_.empty() ? 4 : 5, (int64_t)-100);/' src/SQLiteNestedVFS.h
sed -i.bak '912s/delete_pages_->bind(1, new_page_count);/delete_pages_->bind(1, (int64_t) new_page_count);/' src/SQLiteNestedVFS.h

sed -i.bak '88s/get_dict_->bind(1, dict_id);/get_dict_->bind(1, (int64_t) dict_id);/' src/zstd_vfs.h
sed -i.bak '258s/put_dict_->bind(2, dict_page_count);/put_dict_->bind(2, (int64_t) dict_page_count);/' src/zstd_vfs.h

sed -i.bak '203s/stmt->bind(3, pos);/stmt->bind(3, (int64_t)pos);/' test/test.cc

export CXXFLAGS="$CXXFLAGS -fpermissive"

cmake --build build

mkdir -p $PREFIX/lib
find . -name *zstd_vfs$SHLIB_EXT* -exec ls -l {} \;
cp $(find . -name zstd_vfs$SHLIB_EXT | tail -n 1) $PREFIX/lib

echo '.quit' | sqlite3 -cmd ".load zstd_vfs"
