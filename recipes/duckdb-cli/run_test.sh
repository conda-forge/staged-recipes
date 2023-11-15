for extension in httpfs parquet
do
	duckdb -unsigned -s "INSTALL '$PREFIX/extension/$extension/$extension.duckdb_extension';"
	duckdb -unsigned -s "LOAD '$PREFIX/extension/$extension/$extension.duckdb_extension';"
done

duckdb -unsigned -s "FROM duckdb_extensions()"
