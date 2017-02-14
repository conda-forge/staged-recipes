#!/bin/bash

# Avoid some permissions error on builds
mkdir $PREFIX/.npm-cache
npm config set prefix $PREFIX -g
npm config set cache $PREFIX/.npm-cache -g

npm cache clean
npm install -g .
