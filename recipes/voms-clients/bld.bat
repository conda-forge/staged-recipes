call mvn -Dmaven.javadoc.skip=true -Dvoms-clients.libs="%PREFIX%\share\voms-clients\lib" package
if errorlevel 1 exit 1

dir target
7za x -so "target\voms-clients.tar.gz" | 7za x -si -aoa -ttar > NUL 2>&1
if errorlevel 1 exit 1

dir
dir voms-clients
dir voms-clients\bin
copy "voms-clients\bin\*" "%PREFIX%\bin\"
if errorlevel 1 exit 1

mkdir -p "${PREFIX}\share\voms-clients\lib"
if errorlevel 1 exit 1

dir voms-clients\share
dir voms-clients\share\java
copy "voms-clients\share\java\*" "${PREFIX}\share\voms-clients\lib"
if errorlevel 1 exit 1
