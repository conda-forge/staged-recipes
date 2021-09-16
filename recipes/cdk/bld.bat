# Skip the tests because they require to have a tango database running
cmd.exe /c mvn install -DskipTests

# Generate third party license report
cmd.exe /c mvn license:aggregate-third-party-report
copy "target\site\aggregate-third-party-report.html" "%RECIPE_DIR%"

copy "bundle\target\cdk-%PKG_VERSION%.jar" "%LIBRARY_LIB%\"
