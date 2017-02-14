#!/bin/bash

echo $USER

# Avoid some permissions error on builds
mkdir /tmp/.npm-cache
npm config set prefix $PREFIX -g
npm config set cache /tmp/.npm-cache -g

npm cache clean
npm install -g .
