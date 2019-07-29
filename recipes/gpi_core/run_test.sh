#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    OUTPUT=`gpi --nogui repo_contents/testNets/TestNetwork.net | grep "gpi.canvasGraph:384"`
    if [-z "$OUTPUT" ]; then
        echo "Test Network Failed! Output was not successful completion of network" 1>&2
        exit 1
    else
        echo "Test Network Executed Successfully!"
    fi
fi

if [ "$(uname)" == "Linux" ]; then
    echo "Linux Test not currently available."
#    export DISPLAY=localhost:1.0
#    OUTPUT_1=`Display=localhost:1.0 xvfb-run -a bash -c "gpi --nogui repo_contents/testNets/TestNetwork_NoMatplotlib.net"`
#    OUTPUT=`echo $OUTPUT_1 | grep "gpi.canvasGraph:384"`
#    echo "Ran Linux Test"
fi
