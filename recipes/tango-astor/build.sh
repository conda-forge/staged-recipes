# Update the version in pom files (remove SNAPSHOT)
mvn versions:set versions:update-child-modules -DnewVersion="${PKG_VERSION}" -DprocessAllModule -DgenerateBackupPoms=false -Prelease
# Skip the tests because they require to have a tango database running
mvn install -DskipTests -Dmaven.compiler.source=8 -Dmaven.compiler.target=8

# Generate third party license report
mvn license:aggregate-third-party-report
cp target/site/aggregate-third-party-report.html .

mkdir -p ${PREFIX}/share/java

install -m 0644 target/Astor-${PKG_VERSION}-jar-with-dependencies.jar ${PREFIX}/share/java
ln -s Astor-${PKG_VERSION}-jar-with-dependencies.jar ${PREFIX}/share/java/Astor.jar

# Create astor script
cat << EOF > $PREFIX/bin/astor
#!/bin/sh

if [ ! \$TANGO_HOST ] && [ -f /etc/tangorc ]; then
   . /etc/tangorc
fi

export CLASSPATH=${PREFIX}/share/java/Astor.jar

java \
    -mx128m \
    -DTANGO_HOST=\$TANGO_HOST \
    admin.astor.Astor \$@
EOF
chmod a+x $PREFIX/bin/astor
