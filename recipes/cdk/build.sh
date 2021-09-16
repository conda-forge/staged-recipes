mvn install -DskipTests

# Generate third party license report
mvn license:aggregate-third-party-report
cp target/site/aggregate-third-party-report.html ${RECIPE_DIR}

mkdir -p ${PREFIX}/share/java

install -m 0644 bundle/target/cdk-${PKG_VERSION}.jar ${PREFIX}/share/java
ln -s cdk-${PKG_VERSION}.jar ${PREFIX}/share/java/cdk.jar
