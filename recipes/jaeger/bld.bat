copy example-hotrod.exe "%LIBRARY_BIN%"
if errorlevel 1 exit 1
copy jaeger-agent.exe "%LIBRARY_BIN%"
if errorlevel 1 exit 1
copy jaeger-all-in-one.exe "%LIBRARY_BIN%"
if errorlevel 1 exit 1
copy jaeger-collector.exe "%LIBRARY_BIN%"
if errorlevel 1 exit 1
copy jaeger-ingester.exe "%LIBRARY_BIN%"
if errorlevel 1 exit 1
copy jaeger-query.exe "%LIBRARY_BIN%"
if errorlevel 1 exit 1