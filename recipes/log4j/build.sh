mkdir -p ${PREFIX}/share/java

install -m 0644 log4j-${PKG_VERSION}.jar ${PREFIX}/share/java
ln -s log4j-${PKG_VERSION}.jar ${PREFIX}/share/java/log4j.jar
