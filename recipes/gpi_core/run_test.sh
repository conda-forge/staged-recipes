#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    OUTPUT=`gpi --nogui repo_contents/testNets/TestNetwork.net | grep "gpi.canvasGraph:384"`
fi

if [ "$(uname)" == "Linux" ]; then
    echo "Trying to run Linux Test"
    OUTPUT=`DISPLAY=localhost:1.0 xvfb-run -a bash -c "gpi --nogui repo_contents/testNets/TestNetwork.net | grep \"gpi.canvasGraph:384\" "`
    echo "Ran linux test"
fi

echo "$OUTPUT"
 
if [-z "$OUTPUT" ]
then
  echo "Test Network Failed! Output was not successful completion of network" 1>&2
  exit 1
else
  echo "Test Network Executed Successfully!"
fi
