#!/bin/bash
OUTPUT=`gpi --nogui repo_contents/testNets/TestNetwork.net | grep "gpi.canvasGraph:384"`
if [-z "$OUTPUT" ]
then
  echo "Test Network Failed! Output was not successful completion of network" 1>&2
  exit 1
else
  echo "Test Network Executed Successfully!"
fi
