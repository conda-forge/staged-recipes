#!/bin/bash +x
if [ "$(uname)" == "Darwin" ]; then
    OUTPUT=`gpi --nogui repo_contents/testNets/TestNetwork.net | grep "gpi.canvasGraph:384"`

echo "$OUTPUT"

if [-z "$OUTPUT" ];
then
  echo "Test Network Failed! Output was not successful completion of network" 1>&2
  exit 1
else
  echo "Test Network Executed Successfully!"
fi
fi

# if [ "$(uname)" == "Linux" ]; then
#     echo "Trying to run Linux Test"
#     DISPLAY=localhost:1.0 xvfb-run -a bash -c "gpi --nogui repo_contents/testNets/TestNetwork.net"
#     echo "Ran Test"
# fi
