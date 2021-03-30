mkdir -p ${PREFIX}/usr/share/java

install -m 0644 JTango-${PKG_VERSION}.jar ${PREFIX}/usr/share/java
ln -s JTango-${PKG_VERSION}.jar ${PREFIX}/usr/share/java/JTango.jar
