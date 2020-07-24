set -x
mvn package
mkdir -p $PREFIX/jars
cp social/target/apicurio-keycloak-extensions-social-{{ version }}.Final.jar $PREFIX/jars