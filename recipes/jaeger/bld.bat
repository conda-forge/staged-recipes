copy cmd/all-in-one/all-in-one-windows "%LIBRARY_BIN\all-in-one.exe"
if errorlevel 1 exit 1
copy cmd/agent/agent-windows "%LIBRARY_BIN\agent.exe"
if errorlevel 1 exit 1
copy cmd/query/query-windows "%LIBRARY_BIN\query.exe"
if errorlevel 1 exit 1
copy cmd/collector/collector-windows "%LIBRARY_BIN\collector.exe"
if errorlevel 1 exit 1
copy cmd/ingester/ingester-windows "%LIBRARY_BIN\ingester.exe"
if errorlevel 1 exit 1
copy examples/hotrod/hotrod-windows "%LIBRARY_BIN\hotrod.exe"
if errorlevel 1 exit 1
