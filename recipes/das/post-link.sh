#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    pip install "tensorflow==2.15.1" "tensorflow-metal==1.1.0"
fi