#!/bin/bash -euo

# Install Beakerx...
# ...waiting for a Maven artifact.
# This manual installation will be removed as soon as BeakerX release Maven artifact.
cd $RECIPE_DIR/

git clone https://github.com/twosigma/beakerx.git
cd beakerx/
git checkout 585f07c5dfe7f9f0f97053d90ffc5a696d972382
./gradlew -p kernel/base publishToMavenLocal
cd $RECIPE_DIR/ && rm -fr beakerx

# Install Scijava Jupyter Kernel
cd $SRC_DIR/
mkdir "$PREFIX/opt/scijava-jupyter-kernel"
mvn install -Pimagej --settings "$RECIPE_DIR/settings.xml"
