# Update the version in pom files (remove SNAPSHOT)
mvn versions:set versions:update-child-modules -DnewVersion="${PKG_VERSION}" -DprocessAllModule -DgenerateBackupPoms=false -Prelease
# Skip the tests because they require to have a tango database running
mvn install -DskipTests

# Generate third party license report
mvn license:aggregate-third-party-report
cp target/site/aggregate-third-party-report.html .

mkdir -p ${PREFIX}/share/java

install -m 0644 target/ATKTuning-${PKG_VERSION}.jar ${PREFIX}/share/java
ln -s ATKTuning-${PKG_VERSION}.jar ${PREFIX}/share/java/ATKTuning.jar

# Create atktuning script
cat << EOF > $PREFIX/bin/atktuning
#!/bin/sh

if [ ! \$TANGO_HOST ] && [ -f /etc/tangorc ]; then
   . /etc/tangorc
fi

if [ ! \$TANGO_HOST ]; then
  echo "Please define a TANGO_HOST environment variable pointing to your TANGO database."
  exit 1
fi

TANGO=${PREFIX}/share/java/JTango.jar
TANGOATK=${PREFIX}/share/java/ATKCore.jar:${PREFIX}/share/java/ATKWidget.jar
ATKTUNING=${PREFIX}/share/java/ATKTuning.jar

export CLASSPATH=\$ATKTUNING:\$TANGOATK:\$TANGO
LOGBACK=\${TANGO_LOGBACK:-$PREFIX/share/tango/logback.xml}

java \
  -DTANGO_HOST=\$TANGO_HOST \
  -Dlogback.configurationFile="\$LOGBACK" \
  atktuning.MainPanel \
  "\$@"
EOF
chmod a+x $PREFIX/bin/atktuning
