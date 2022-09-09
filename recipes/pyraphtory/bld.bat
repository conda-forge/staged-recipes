@echo off

echo "Getting version"
cd $SRC_DIR && make version

echo "Running make sbt-build..."
cd $SRC_DIR && make sbt-build

echo "Running make python-build..."
cd $SRC_DIR && make python-build

echo "Running make clean"
cd $SRC_DIR && make clean