#!/bin/bash

# Avoid some permissions error on builds
# mkdir $PREFIX/.npm-global
npm config set prefix $PREFIX -g
npm config set cache $PREFIX -g

npm cache clean
npm install -g .
