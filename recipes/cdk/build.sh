# Skip the tests because they require to have a tango database running
mvn install -DskipTests

# Generate third party license report
mvn license:aggregate-third-party-report
cp target/site/aggregate-third-party-report.html .

mkdir -p ${PREFIX}/share/java

install -m 0644 ${BUILD_PREFIX}/assembly/target/cdk-${PKG_VERSION}.jar ${PREFIX}/share/java
ln -s cdk-${PKG_VERSION}.jar ${PREFIX}/share/java/cdk.jar
