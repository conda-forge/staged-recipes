set -x
mvn package
mkdir -p $PREFIX/jars
cp social/target/apicurio-keycloak-extensions-social-$PKG_VERSION.Final.jar $PREFIX/jars