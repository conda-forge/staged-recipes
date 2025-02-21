#!/bin/bash
set -ex  # Fail on error and print each command

# Build the project using Maven
mvn clean package

# Create installation directory
mkdir -p "${PREFIX}/share/rnartistcore"

# Copy the built JAR file to the installation directory
cp target/rnartistcore-*-jar-with-dependencies.jar "${PREFIX}/share/rnartistcore/rnartistcore.jar"

# Create bin directory if not present
mkdir -p "${PREFIX}/bin"

# Create an executable wrapper script to run the jar file
cat <<EOF > "${PREFIX}/bin/rnartistcore"
#!/bin/bash
exec java -jar "\${CONDA_PREFIX}/share/rnartistcore/rnartistcore.jar" "\$@"
EOF
chmod +x "${PREFIX}/bin/rnartistcore"
