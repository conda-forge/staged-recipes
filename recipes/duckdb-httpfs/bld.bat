
set pkg_os=windows

@REM download
echo "Downloading version %PKG_VERSION% for windows to %PREFIX%"
curl "http://extensions.duckdb.org/v%PKG_VERSION%/windows/httpfs.duckdb_extension.gz" --output  "%PREFIX%/httpfs.duckdb_extension.gz"