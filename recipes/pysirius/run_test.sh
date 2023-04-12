#!/bin/sh

echo "### TEST ENV INFO"
echo "PREFIX=$PREFIX"
echo "CONDA_PREFIX=$CONDA_PREFIX"
echo "LD_RUN_PATH=$LD_RUN_PATH"
echo "JAVA_HOME = $JAVA_HOME"
echo "JDK_HOME = $JDK_HOME"
echo "ARCH = $ARCH"
echo "OSX_ARCH = $OSX_ARCH"
echo "RECIPE_DIR = $RECIPE_DIR"
echo "### TEST ENV INFO END"

echo "### [JAVA] Try run java"
java -version

echo "### [JAVA] Try run $JAVA_HOME"
"$JAVA_HOME/bin/java" -version

echo "### [SIRIUS API] Run Sirius test script"
$PYTHON "$RECIPE_DIR/test_script.py"

echo "### [SIRIUS] Check SIRIUS test script results"
if [ ! -f "test_fragtree.txt" ]; then
  echo Framgentation tree test failed!
  exit 1
fi