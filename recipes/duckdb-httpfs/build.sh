PKG_OS=`echo "$build_platform" | sed "s/-64/_amd64/"` # [os]-64 (conda) -> [os]_amd64 (duckdb)

# download
echo "Downloading version ${PKG_VERSION} for ${PKG_OS} to ${PREFIX}"
curl "http://extensions.duckdb.org/v$PKG_VERSION/$PKG_OS/httpfs.duckdb_extension.gz" --output  "${PREFIX}/httpfs.duckdb_extension.gz"