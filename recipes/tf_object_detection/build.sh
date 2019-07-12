#!/usr/bin/env bash
cd research
if [`uname` == Darwin];then
    curl -OL https://github.com/google/protobuf/releases/download/v3.3.0/$PROTOC_ZIP
    sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
    rm -f $PROTOC_ZIP
    protoc object_detection/protos/*.proto --python_out=.
fi

if [`uname` == Linux ]; then

    wget -O protobuf.zip https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip
    unzip protobuf.zip
    ./bin/protoc object_detection/protos/*.proto --python_out=.
fi


$PYTHON setup.py install --single-version-externally-managed --record=record.txt # solution for error: check https://github.com/conda/conda/issues/508
