#!/bin/sh

echo "### TEST ENV INFO"
echo "PREFIX=$PREFIX"
echo "CONDA_PREFIX=$CONDA_PREFIX"
echo "LD_RUN_PATH=$LD_RUN_PATH"
echo "JAVA_HOME = $JAVA_HOME"
echo "JDK_HOME = $JDK_HOME"
echo "### TEST ENV INFO END"

echo "### [JAVA] Try run java"
java -version

echo "### [JAVA] Try run $JAVA_HOME"
"$JAVA_HOME/bin/java" -version

echo "### [SIRIUS] Simple Sirius version test"
sirius.sh --version

echo "### [SIRIUS] Run SIRIUS ILP solver Test"
sirius.sh -i $RECIPE_DIR/Kaempferol.ms -o test-out sirius

echo "### [SIRIUS] Check SIRIUS ILP solver Test results"
if [ ! -f "test-out/1_Kaempferol_Kaempferol/trees" ]; then
  echo Framgentation tree test failed!
  exit 1
fi
