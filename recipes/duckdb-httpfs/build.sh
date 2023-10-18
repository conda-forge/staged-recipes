PKG_OS=`echo "$build_platform" | sed "s/-64/_amd64/"` # [os]-64 (conda) -> [os]_amd64 (duckdb)
PKG_OS=`echo "$PKG_OS" | sed "s/win/windows/"`        # win -> windows

# download
echo "Downloading version ${PKG_VERSION} for ${PKG_OS}"
curl "http://extensions.duckdb.org/v$PKG_VERSION/$PKG_OS/httpfs.duckdb_extension.gz" --output "${PREFIX}httpfs.duckdb_extension.gz"
