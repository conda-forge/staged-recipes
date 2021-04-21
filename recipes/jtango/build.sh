mkdir -p ${PREFIX}/share/java

install -m 0644 JTango-${PKG_VERSION}.jar ${PREFIX}/share/java
ln -s JTango-${PKG_VERSION}.jar ${PREFIX}/share/java/JTango.jar
