#!/usr/bin/env bash

ENV_NAME=test-fiftyone

rm ~/.conda/envs/$ENV_NAME -rf || true

conda create -y -n $ENV_NAME \
  -c ./build_artifacts/channeldata.json \
  -c conda-forge \
  fiftyone jupyter

conda run --no-capture-output -n $ENV_NAME \
  jupyter notebook --ServerApp.ip=0.0.0.0
